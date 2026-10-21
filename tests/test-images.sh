#!/bin/sh
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASSED=0
FAILED=0

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

pass() {
    printf "${GREEN}  ✓ %s${NC}\n" "$1"
    PASSED=$((PASSED + 1))
}

fail() {
    printf "${RED}  ✗ %s${NC}\n" "$1"
    FAILED=$((FAILED + 1))
}

info() {
    printf "\n${YELLOW}==> %s${NC}\n" "$1"
}

assert_contains() {
    haystack="$1"
    needle="$2"
    msg="$3"
    if printf "%s" "$haystack" | grep -qi "$needle"; then
        pass "$msg"
    else
        fail "$msg (expected '$needle')"
    fi
}

assert_not_contains() {
    haystack="$1"
    needle="$2"
    msg="$3"
    if printf "%s" "$haystack" | grep -qi "$needle"; then
        fail "$msg (unexpected '$needle' found)"
    else
        pass "$msg"
    fi
}

# Extract major.minor PHP version from variant name (e.g., php8.5-oci8 -> 8.5, 8.5 -> 8.5)
extract_php_version() {
    printf "%s" "$1" | sed -E 's/^php//; s/([0-9]+\.[0-9]+).*/\1/'
}

# Determine extra extensions expected for a variant
get_extra_extensions() {
    variant="$1"
    extra=""
    case "$variant" in
        *-oci8*)
            extra="$extra oci8 redis"
            ;;
    esac
    case "$variant" in
        *-octane*)
            extra="$extra swoole pcntl posix"
            ;;
    esac
    printf "%s" "$extra"
}

test_variant() {
    RAW_TARGET="$1"
    PORT="$2"
    EXISTING_IMAGE="$3"

    # Normalize directory name (accept both "8.5" and "php8.5")
    case "$RAW_TARGET" in
        php*) VARIANT="$RAW_TARGET" ;;
        *)    VARIANT="php${RAW_TARGET}" ;;
    esac

    PHP_VER=$(extract_php_version "$VARIANT")
    EXTRA_EXTENSIONS=$(get_extra_extensions "$VARIANT")
    CONTAINER_NAME="test-container-${VARIANT}"
    VARIANT_DIR="${ROOT_DIR}/${VARIANT}"

    if [ -n "$EXISTING_IMAGE" ]; then
        IMAGE_TAG="$EXISTING_IMAGE"
    else
        IMAGE_TAG="web-php-test:${VARIANT}"
    fi

    info "Testing variant: ${VARIANT} (PHP ${PHP_VER}, Image: ${IMAGE_TAG})"

    # Ensure any leftover container is removed
    docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true

    # 1. Build image locally only if an existing built image was not provided
    if [ -z "$EXISTING_IMAGE" ]; then
        if [ ! -d "$VARIANT_DIR" ]; then
            fail "Directory $VARIANT_DIR does not exist"
            return 1
        fi
        printf "  Building image %s...\n" "$IMAGE_TAG"
        if docker build --platform=linux/amd64 -t "$IMAGE_TAG" "$VARIANT_DIR" >/tmp/build-${VARIANT}.log 2>&1; then
            pass "Docker build succeeded for ${VARIANT}"
        else
            fail "Docker build failed for ${VARIANT} (see /tmp/build-${VARIANT}.log)"
            cat "/tmp/build-${VARIANT}.log"
            return 1
        fi
    else
        if docker image inspect "$IMAGE_TAG" >/dev/null 2>&1; then
            pass "Using pre-built image ${IMAGE_TAG}"
        else
            fail "Pre-built image ${IMAGE_TAG} not found locally"
            return 1
        fi
    fi

    # 2. Print detailed installed versions (OS, Nginx, PHP, Composer, APK packages, PHP extensions)
    printf "\n  ${YELLOW}--- Installed Software & Package Versions (${VARIANT}) ---${NC}\n"
    docker run --rm --platform=linux/amd64 --entrypoint sh "$IMAGE_TAG" -c '
        echo "  [OS / Alpine]"
        printf "    Alpine Linux: %s\n" "$(cat /etc/alpine-release 2>/dev/null || echo unknown)"
        printf "    Kernel:       %s\n" "$(uname -sr)"
        echo ""
        echo "  [Core Services]"
        printf "    PHP CLI:      %s\n" "$(php -v 2>/dev/null | head -n 1)"
        printf "    PHP-FPM:      %s\n" "$(/usr/local/sbin/php-fpm -v 2>/dev/null | head -n 1 || php-fpm -v 2>/dev/null | head -n 1 || echo unknown)"
        printf "    Nginx:        %s\n" "$(nginx -v 2>&1)"
        printf "    Composer:     %s\n" "$(composer --version 2>/dev/null | head -n 1)"
        printf "    OpenSSL:      %s\n" "$(openssl version 2>/dev/null || echo unknown)"
        printf "    cURL:         %s\n" "$(curl --version 2>/dev/null | head -n 1)"
        if [ -d "/opt/oracle/instantclient" ]; then
            printf "    Oracle IC:    %s\n" "$(ls -d /opt/oracle/instantclient_* 2>/dev/null | head -n 1)"
        fi
        echo ""
        echo "  [Installed Alpine Packages (apk info -v)]"
        apk info -v 2>/dev/null | sort | sed "s/^/    - /"
        echo ""
        echo "  [Loaded PHP Extensions & Versions]"
        php -r '\''
            $exts = get_loaded_extensions();
            natcasesort($exts);
            foreach ($exts as $ext) {
                $ver = phpversion($ext);
                printf("    - %-20s %s\n", $ext, $ver ? $ver : "(built-in)");
            }
        '\''
    ' || true
    printf "  ${YELLOW}----------------------------------------------------------${NC}\n\n"

    # 3. Check PHP CLI version
    PHP_VER_OUT=$(docker run --rm --platform=linux/amd64 --entrypoint php "$IMAGE_TAG" -v 2>&1 || true)
    assert_contains "$PHP_VER_OUT" "PHP ${PHP_VER}" "PHP ${PHP_VER} CLI is installed"

    # 4. Check Composer
    COMPOSER_OUT=$(docker run --rm --platform=linux/amd64 --entrypoint composer "$IMAGE_TAG" --version 2>&1 || true)
    assert_contains "$COMPOSER_OUT" "Composer version" "Composer is installed and runnable"

    # 5. Check required Alpine system packages
    APK_OUT=$(docker run --rm --platform=linux/amd64 --entrypoint apk "$IMAGE_TAG" info 2>&1 || true)
    for pkg in xvfb fontconfig dbus; do
        assert_contains "$APK_OUT" "$pkg" "Alpine package installed: $pkg"
    done
    if printf "%s" "$APK_OUT" | grep -qiE "ttf-freefont|font-freefont"; then
        pass "Alpine package installed: ttf-freefont"
    else
        fail "Alpine package installed: ttf-freefont (expected 'ttf-freefont' or 'font-freefont')"
    fi

    # 6. Check loaded PHP extensions
    MODULES_OUT=$(docker run --rm --platform=linux/amd64 --entrypoint php "$IMAGE_TAG" -m 2>&1 || true)
    BASE_EXTENSIONS="ctype curl dom fileinfo gd iconv intl json mbstring mysqlnd Zend OPcache openssl pdo pdo_mysql phar redis session simplexml sockets sodium tokenizer xml xmlreader xmlwriter zip zlib"

    for ext in $BASE_EXTENSIONS $EXTRA_EXTENSIONS; do
        assert_contains "$MODULES_OUT" "$ext" "Extension loaded: $ext"
    done

    # 5. Check php.ini configuration and expose_php directive
    INI_OUT=$(docker run --rm --platform=linux/amd64 --entrypoint php "$IMAGE_TAG" --ini 2>&1 || true)
    assert_contains "$INI_OUT" "php.ini" "Custom php.ini is loaded"

    EXPOSE_PHP=$(docker run --rm --platform=linux/amd64 --entrypoint php "$IMAGE_TAG" -r "echo ini_get('expose_php');" 2>&1 || true)
    if [ "$EXPOSE_PHP" = "" ] || [ "$EXPOSE_PHP" = "0" ]; then
        pass "php.ini directive expose_php is Off"
    else
        fail "php.ini directive expose_php expected Off, got '$EXPOSE_PHP'"
    fi

    # 6. Start container and test runtime services (s6-overlay + Nginx + PHP-FPM)
    printf "  Starting container %s on port %s...\n" "$CONTAINER_NAME" "$PORT"
    docker run -d --platform=linux/amd64 --name "$CONTAINER_NAME" -p "${PORT}:80" "$IMAGE_TAG" >/dev/null

    # Wait for Nginx & PHP-FPM to become ready (up to 15 seconds)
    READY=0
    for _ in $(seq 1 15); do
        if curl -fsS "http://localhost:${PORT}/" >/dev/null 2>&1 || docker exec "$CONTAINER_NAME" curl -fsS "http://127.0.0.1/ping" >/dev/null 2>&1; then
            READY=1
            break
        fi
        sleep 1
    done

    if [ "$READY" -eq 1 ]; then
        pass "Container started and Nginx + PHP-FPM are ready"
    else
        fail "Container failed to respond within 15s"
        docker logs "$CONTAINER_NAME" || true
    fi

    # 7. Test HTTP response & headers (skip index.php phpinfo check on Octane variants where port 8000 awaits artisan)
    case "$VARIANT" in
        *-octane*)
            ;;
        *)
            HEADERS=$(curl -sI "http://localhost:${PORT}/" || true)
            BODY=$(curl -s "http://localhost:${PORT}/" || true)

            assert_contains "$HEADERS" "200 OK" "GET / returns HTTP 200 OK"
            assert_not_contains "$HEADERS" "X-Powered-By" "Header X-Powered-By is hidden"
            assert_contains "$HEADERS" "X-Frame-Options: SAMEORIGIN" "Security header X-Frame-Options is present"
            assert_contains "$HEADERS" "X-Content-Type-Options: nosniff" "Security header X-Content-Type-Options is present"
            assert_contains "$BODY" "PHP Version ${PHP_VER}" "GET / renders phpinfo() output via PHP-FPM"
            ;;
    esac

    # 8. Test PHP-FPM /ping and /status endpoints (allowed from 127.0.0.1 inside container)
    PING_BODY=$(docker exec "$CONTAINER_NAME" curl -s "http://127.0.0.1/ping" || true)
    assert_contains "$PING_BODY" "pong" "GET /ping (internal 127.0.0.1) returns 'pong'"

    STATUS_BODY=$(docker exec "$CONTAINER_NAME" curl -s "http://127.0.0.1/status" || true)
    assert_contains "$STATUS_BODY" "phpfpm_" "GET /status (internal 127.0.0.1) returns PHP-FPM openmetrics status"

    # Verify external access to /ping is restricted by nginx ACL (returns 403 Forbidden)
    EXT_PING_HEADERS=$(curl -sI "http://localhost:${PORT}/ping" || true)
    assert_contains "$EXT_PING_HEADERS" "403 Forbidden" "GET /ping from external bridge IP is restricted (403 Forbidden)"

    # Cleanup container
    docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
}

TARGET="${1:-all}"
EXISTING_IMAGE="${2:-}"

case "$TARGET" in
    all)
        test_variant "php8.4" 18080 ""
        test_variant "php8.4-oci8" 18081 ""
        test_variant "php8.5" 18082 ""
        test_variant "php8.5-oci8" 18083 ""
        ;;
    8.4)
        test_variant "php8.4" 18080 ""
        test_variant "php8.4-oci8" 18081 ""
        ;;
    8.5)
        test_variant "php8.5" 18080 ""
        test_variant "php8.5-oci8" 18081 ""
        ;;
    *)
        test_variant "$TARGET" 18080 "$EXISTING_IMAGE"
        ;;
esac

printf "\n========================================\n"
printf "Test Summary: ${GREEN}%d passed${NC}, ${RED}%d failed${NC}\n" "$PASSED" "$FAILED"
printf "========================================\n"

if [ "$FAILED" -gt 0 ]; then
    printf "${RED}[ERRO] Os testes da imagem falharam! O envio (push) para o Docker Hub deve ser cancelado.${NC}\n"
    exit 1
fi
