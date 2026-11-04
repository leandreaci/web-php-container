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
            extra="$extra oci8"
            ;;
    esac
    case "$variant" in
        *-octane*)
            extra="$extra swoole pcntl posix"
            ;;
    esac
    printf "%s" "$extra"
}

is_modern_variant() {
    case "$1" in
        8.3|8.4|8.5) return 0 ;;
        *) return 1 ;;
    esac
}

update_readme_status() {
    variant="$1"
    build_ok="$2"
    passed_cnt="$3"
    failed_cnt="$4"
    readme_file="${ROOT_DIR}/readme.md"

    if [ ! -f "$readme_file" ]; then
        return 0
    fi

    if [ "$build_ok" -eq 1 ]; then
        build_badge="![Build](https://img.shields.io/badge/build-passing-brightgreen)"
    else
        build_badge="![Build](https://img.shields.io/badge/build-failing-red)"
    fi

    if [ "$build_ok" -eq 1 ] && [ "$failed_cnt" -eq 0 ]; then
        test_badge="![Tests](https://img.shields.io/badge/tests-${passed_cnt}%20passed-brightgreen)"
    else
        test_badge="![Tests](https://img.shields.io/badge/tests-${failed_cnt}%20failed-red)"
    fi

    sed -i -E "s|(\\| \`${variant}/\` \\| \`[^|]+\` \\| [^|]+ \\|) [^|]+ \\||\\1 ${test_badge} ||" "$readme_file" 2>/dev/null || true
}

test_variant() {
    RAW_TARGET="$1"
    PORT="$2"
    EXISTING_IMAGE="$3"

    VARIANT_PASSED_START=$PASSED
    VARIANT_FAILED_START=$FAILED

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
            update_readme_status "$VARIANT" 0 0 1
            cat "/tmp/build-${VARIANT}.log"
            return 1
        fi
    else
        if docker image inspect "$IMAGE_TAG" >/dev/null 2>&1; then
            pass "Using pre-built image ${IMAGE_TAG}"
        else
            fail "Pre-built image ${IMAGE_TAG} not found locally"
            update_readme_status "$VARIANT" 0 0 1
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

    # 4. Check Composer & Extension Helpers
    if [ "$PHP_VER" != "7.1" ]; then
        COMPOSER_OUT=$(docker run --rm --platform=linux/amd64 --entrypoint composer "$IMAGE_TAG" --version 2>&1 || true)
        assert_contains "$COMPOSER_OUT" "Composer" "Composer is installed and runnable"
    fi

    HELPER_OUT=$(docker run --rm --platform=linux/amd64 --entrypoint sh "$IMAGE_TAG" -c "command -v install-php-extensions && command -v docker-php-ext-enable && command -v docker-php-ext-install && command -v install-headless" 2>&1 || true)
    assert_contains "$HELPER_OUT" "/usr/local/bin/install-php-extensions" "Helper 'install-php-extensions' is available in PATH"
    assert_contains "$HELPER_OUT" "/usr/local/bin/docker-php-ext-enable" "Helper 'docker-php-ext-enable' is available in PATH"
    assert_contains "$HELPER_OUT" "/usr/local/bin/docker-php-ext-install" "Helper 'docker-php-ext-install' is available in PATH"
    assert_contains "$HELPER_OUT" "/usr/local/bin/install-headless" "Helper 'install-headless' is available in PATH"

    if is_modern_variant "$PHP_VER"; then
        OCTANE_HELPER_OUT=$(docker run --rm --platform=linux/amd64 --entrypoint sh "$IMAGE_TAG" -c "command -v octane-install && command -v install-octane" 2>&1 || true)
        assert_contains "$OCTANE_HELPER_OUT" "/usr/local/bin/octane-install" "Helper 'octane-install' is available in PATH"
        assert_contains "$OCTANE_HELPER_OUT" "/usr/local/bin/install-octane" "Helper 'install-octane' is available in PATH"

        # Check headless packages only for -headless variant images
        case "$VARIANT" in
            *-headless*)
                APK_OUT=$(docker run --rm --platform=linux/amd64 --entrypoint apk "$IMAGE_TAG" info 2>&1 || true)
                for pkg in xvfb fontconfig dbus libxrender; do
                    assert_contains "$APK_OUT" "$pkg" "Alpine package installed: $pkg"
                done
                if printf "%s" "$APK_OUT" | grep -qiE "ttf-freefont|font-freefont"; then
                    pass "Alpine package installed: ttf-freefont"
                else
                    fail "Alpine package installed: ttf-freefont (expected 'ttf-freefont' or 'font-freefont')"
                fi
                ;;
        esac
    fi

    # 6. Check loaded PHP extensions
    MODULES_OUT=$(docker run --rm --platform=linux/amd64 --entrypoint php "$IMAGE_TAG" -m 2>&1 || true)
    if is_modern_variant "$PHP_VER"; then
        BASE_EXTENSIONS="ctype curl dom fileinfo ftp gd iconv intl json mbstring mysqlnd Zend OPcache openssl pcntl pdo pdo_mysql phar posix redis session simplexml sockets sodium tokenizer xml xmlreader xmlwriter zip zlib"
    else
        BASE_EXTENSIONS="ctype curl dom json mbstring mysqlnd Zend OPcache openssl pdo pdo_mysql session tokenizer xml zlib"
    fi

    for ext in $BASE_EXTENSIONS $EXTRA_EXTENSIONS; do
        assert_contains "$MODULES_OUT" "$ext" "Extension loaded: $ext"
    done

    # 5. Check php.ini configuration and expose_php directive
    INI_OUT=$(docker run --rm --platform=linux/amd64 --entrypoint php "$IMAGE_TAG" --ini 2>&1 || true)
    assert_contains "$INI_OUT" "php.ini" "Custom php.ini is loaded"

    if is_modern_variant "$PHP_VER"; then
        EXPOSE_PHP=$(docker run --rm --platform=linux/amd64 --entrypoint php "$IMAGE_TAG" -r "echo ini_get('expose_php');" 2>&1 || true)
        if [ "$EXPOSE_PHP" = "" ] || [ "$EXPOSE_PHP" = "0" ]; then
            pass "php.ini directive expose_php is Off"
        else
            fail "php.ini directive expose_php expected Off, got '$EXPOSE_PHP'"
        fi
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
            if is_modern_variant "$PHP_VER"; then
                assert_not_contains "$HEADERS" "X-Powered-By" "Header X-Powered-By is hidden"
            fi
            assert_contains "$HEADERS" "X-Frame-Options: SAMEORIGIN" "Security header X-Frame-Options is present"
            assert_contains "$HEADERS" "X-Content-Type-Options: nosniff" "Security header X-Content-Type-Options is present"
            assert_contains "$BODY" "PHP Version ${PHP_VER}" "GET / renders phpinfo() output via PHP-FPM"
            ;;
    esac

    # 8. Test PHP-FPM /ping and /status endpoints (allowed from 127.0.0.1 inside container on 8.2, 8.4, 8.5)
    case "$PHP_VER" in
        8.2|8.4|8.5)
            PING_BODY=$(docker exec "$CONTAINER_NAME" curl -s "http://127.0.0.1/ping" || true)
            assert_contains "$PING_BODY" "pong" "GET /ping (internal 127.0.0.1) returns 'pong'"

            STATUS_BODY=$(docker exec "$CONTAINER_NAME" curl -s "http://127.0.0.1/status" || true)
            assert_contains "$STATUS_BODY" "phpfpm_" "GET /status (internal 127.0.0.1) returns PHP-FPM openmetrics status"

            # Verify external access to /ping is restricted by nginx ACL (returns 403 Forbidden)
            EXT_PING_HEADERS=$(curl -sI "http://localhost:${PORT}/ping" || true)
            assert_contains "$EXT_PING_HEADERS" "403 Forbidden" "GET /ping from external bridge IP is restricted (403 Forbidden)"
            ;;
    esac

    # Verify apk package manager has been removed from running pod for security hardening
    if docker exec "$CONTAINER_NAME" sh -c "! command -v apk >/dev/null 2>&1 && [ ! -e /sbin/apk ] && [ ! -d /etc/apk ]" >/dev/null 2>&1; then
        pass "Alpine apk binary and directories are removed in running container"
    else
        fail "Alpine apk binary or directories still exist in running container"
    fi

    # 9. If octane variant, verify Swoole HTTP server & Nginx reverse proxy
    case "$VARIANT" in
        *-octane*)
            info "Verifying Laravel Octane Swoole server & Nginx proxy for ${VARIANT}..."
            # Test Swoole CLI extension
            SWOOLE_CLI_CHECK=$(docker exec "$CONTAINER_NAME" php -r "echo extension_loaded('swoole') ? 'swoole_loaded' : 'no';" 2>&1 || true)
            assert_contains "$SWOOLE_CLI_CHECK" "swoole_loaded" "Swoole extension is active in PHP"

            # Run a lightweight mock Swoole HTTP server on 127.0.0.1:8000 inside the container
            docker exec -d "$CONTAINER_NAME" php -r '
                $http = new Swoole\Http\Server("127.0.0.1", 8000);
                $http->on("start", function ($server) {
                    file_put_contents("/tmp/swoole_server.ready", "ready");
                });
                $http->on("request", function ($request, $response) {
                    $response->header("Content-Type", "text/plain");
                    $response->end("Hello from Octane Swoole!");
                });
                $http->start();
            '

            # Wait up to 5 seconds for mock Swoole HTTP server to bind
            SWOOLE_READY=0
            for _ in $(seq 1 10); do
                if docker exec "$CONTAINER_NAME" test -f /tmp/swoole_server.ready; then
                    SWOOLE_READY=1
                    break
                fi
                sleep 0.5
            done

            if [ "$SWOOLE_READY" -eq 1 ]; then
                pass "Swoole HTTP server is listening on 127.0.0.1:8000"
            else
                fail "Swoole HTTP server failed to start on 127.0.0.1:8000"
            fi

            OCTANE_RESP=$(curl -s "http://localhost:${PORT}/" || true)
            assert_contains "$OCTANE_RESP" "Hello from Octane Swoole!" "GET / proxies successfully through Nginx to Octane Swoole (port 8000)"
            ;;
    esac

    # Cleanup container
    docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true

    VARIANT_PASSED=$((PASSED - VARIANT_PASSED_START))
    VARIANT_FAILED=$((FAILED - VARIANT_FAILED_START))
    update_readme_status "$VARIANT" 1 "$VARIANT_PASSED" "$VARIANT_FAILED"
}

TARGET="${1:-all}"
EXISTING_IMAGE="${2:-}"

case "$TARGET" in
    all)
        test_variant "php7.3" 18073 ""
        test_variant "php7.4" 18075 ""
        test_variant "php8.0" 18080 ""
        test_variant "php8.1" 18082 ""
        test_variant "php8.2" 18084 ""
        test_variant "php8.3" 18085 ""
        test_variant "php8.4" 18086 ""
        test_variant "php8.5" 18087 ""
        ;;
    modern)
        test_variant "php8.3" 18080 ""
        test_variant "php8.4" 18082 ""
        test_variant "php8.5" 18084 ""
        ;;
    8.3)
        test_variant "php8.3" 18080 ""
        ;;
    8.4)
        test_variant "php8.4" 18080 ""
        ;;
    8.5)
        test_variant "php8.5" 18080 ""
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
