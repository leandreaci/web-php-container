# Web PHP Container (PHP-FPM + Nginx on Alpine Linux)

[![PHP 8.5](https://github.com/renatobalbino/web-php-container/actions/workflows/php8.5.yml/badge.svg)](https://github.com/renatobalbino/web-php-container/actions/workflows/php8.5.yml)
[![PHP 8.4](https://github.com/renatobalbino/web-php-container/actions/workflows/php8.4.yml/badge.svg)](https://github.com/renatobalbino/web-php-container/actions/workflows/php8.4.yml)
[![PHP 8.3](https://github.com/renatobalbino/web-php-container/actions/workflows/php8.3.yml/badge.svg)](https://github.com/renatobalbino/web-php-container/actions/workflows/php8.3.yml)
[![PHP 8.2](https://github.com/renatobalbino/web-php-container/actions/workflows/php8.2.yml/badge.svg)](https://github.com/renatobalbino/web-php-container/actions/workflows/php8.2.yml)
[![PHP 8.1](https://github.com/renatobalbino/web-php-container/actions/workflows/php8.1.yml/badge.svg)](https://github.com/renatobalbino/web-php-container/actions/workflows/php8.1.yml)
[![PHP 8.0](https://github.com/renatobalbino/web-php-container/actions/workflows/php8.0.yml/badge.svg)](https://github.com/renatobalbino/web-php-container/actions/workflows/php8.0.yml)
[![PHP 7.4](https://github.com/renatobalbino/web-php-container/actions/workflows/php7.4.yml/badge.svg)](https://github.com/renatobalbino/web-php-container/actions/workflows/php7.4.yml)
[![PHP 7.3](https://github.com/renatobalbino/web-php-container/actions/workflows/php7.3.yml/badge.svg)](https://github.com/renatobalbino/web-php-container/actions/workflows/php7.3.yml)
![Alpine Linux](https://img.shields.io/badge/Alpine_Linux-3.21%20%7C%20edge-0D597F?logo=alpinelinux)
![Hardened](https://img.shields.io/badge/security-apk%20purged%20at%20runtime-blue?logo=linux)

Production-ready, hardened, and optimized Docker images for PHP applications (Laravel / Lumen / Octane / generic PHP), based on **Alpine Linux** with **native Alpine PHP packages (`apk`)** across all versions, **Nginx Mainline**, **Composer 2**, multi-stage build patterns, on-demand extension & Octane installation helpers (`install-php-extensions`, `octane-install`, `install-headless`), and process management via **s6-overlay**.

---

## 📦 Available Variants & GitHub Build/Test Status

> Each variant below has its own live **GitHub Actions Build Status** badge pointing to [`renatobalbino/web-php-container`](https://github.com/renatobalbino/web-php-container/actions) and a **Test Suite** badge updated automatically by `./tests/test-images.sh`.

### Active Primary Variants (PHP 8.0+ with Multi-Stage Builds & `-headless` Variants)

| Variant | Directory | Alpine Base | Image Tags | GitHub Build Status | Test Suite | Description |
| :--- | :--- | :--- | :--- | :---: | :---: | :--- |
| **PHP 8.5** | `php8.5/` | `alpine:edge` | `renatobalbino/php:8.5`<br>`renatobalbino/php:8.5-headless` | [![PHP 8.5](https://github.com/renatobalbino/web-php-container/actions/workflows/php8.5.yml/badge.svg)](https://github.com/renatobalbino/web-php-container/actions/workflows/php8.5.yml) | ![Tests](https://img.shields.io/badge/tests-51%20passed-brightgreen) | PHP 8.5.12 + Nginx + Redis + `install-headless` + `octane-install` (~236 MB base / ~592 MB headless) |
| **PHP 8.4** | `php8.4/` | `alpine:3.21` | `renatobalbino/php:8.4`<br>`renatobalbino/php:8.4-headless` | [![PHP 8.4](https://github.com/renatobalbino/web-php-container/actions/workflows/php8.4.yml/badge.svg)](https://github.com/renatobalbino/web-php-container/actions/workflows/php8.4.yml) | ![Tests](https://img.shields.io/badge/tests-51%20passed-brightgreen) | PHP 8.4.27 + Nginx + Redis + `install-headless` + `octane-install` (~192 MB base / ~600 MB headless) |
| **PHP 8.3** | `php8.3/` | `alpine:3.21` | `renatobalbino/php:8.3`<br>`renatobalbino/php:8.3-headless` | [![PHP 8.3](https://github.com/renatobalbino/web-php-container/actions/workflows/php8.3.yml/badge.svg)](https://github.com/renatobalbino/web-php-container/actions/workflows/php8.3.yml) | ![Tests](https://img.shields.io/badge/tests-48%20passed-brightgreen) | PHP 8.3.36 + Nginx + Redis + `install-headless` + `octane-install` (~187 MB base / ~596 MB headless) |
| **PHP 8.2** | `php8.2/` | `alpine:3.21` | `renatobalbino/php:8.2`<br>`renatobalbino/php:8.2-headless` | [![PHP 8.2](https://github.com/renatobalbino/web-php-container/actions/workflows/php8.2.yml/badge.svg)](https://github.com/renatobalbino/web-php-container/actions/workflows/php8.2.yml) | ![Tests](https://img.shields.io/badge/tests-32%20passed-brightgreen) | PHP 8.2.35 + Nginx + Redis + `install-headless` + Composer 2 (~157 MB base / ~567 MB headless) |
| **PHP 8.1** | `php8.1/` | `alpine:3.19` | `renatobalbino/php:8.1`<br>`renatobalbino/php:8.1-headless` | [![PHP 8.1](https://github.com/renatobalbino/web-php-container/actions/workflows/php8.1.yml/badge.svg)](https://github.com/renatobalbino/web-php-container/actions/workflows/php8.1.yml) | ![Tests](https://img.shields.io/badge/tests-29%20passed-brightgreen) | PHP 8.1.34 + Nginx + `install-headless` + Composer 2 (~154 MB base / ~204 MB headless) |
| **PHP 8.0** | `php8.0/` | `alpine:3.16` | `renatobalbino/php:8.0`<br>`renatobalbino/php:8.0-headless` | [![PHP 8.0](https://github.com/renatobalbino/web-php-container/actions/workflows/php8.0.yml/badge.svg)](https://github.com/renatobalbino/web-php-container/actions/workflows/php8.0.yml) | ![Tests](https://img.shields.io/badge/tests-29%20passed-brightgreen) | PHP 8.0.30 + Nginx + `install-headless` + Composer 2 (~145 MB base / ~199 MB headless) |

### Legacy Variants (With `install-php-extensions`, `install-headless` & Runtime Hardening)

| Variant | Directory | Alpine Base | Image Tag | GitHub Build Status | Test Suite | Description |
| :--- | :--- | :--- | :--- | :---: | :---: | :--- |
| **PHP 7.4** | `php7.4/` | `alpine:3.14` | `renatobalbino/php:7.4` | [![PHP 7.4](https://github.com/renatobalbino/web-php-container/actions/workflows/php7.4.yml/badge.svg)](https://github.com/renatobalbino/web-php-container/actions/workflows/php7.4.yml) | ![Tests](https://img.shields.io/badge/tests-28%20passed-brightgreen) | PHP 7.4.33 + Nginx + Composer 2 + `install-php-extensions` + `install-headless` (~210 MB) |
| **PHP 7.3** | `php7.3/` | `alpine:3.12` | `renatobalbino/php:7.3` | [![PHP 7.3](https://github.com/renatobalbino/web-php-container/actions/workflows/php7.3.yml/badge.svg)](https://github.com/renatobalbino/web-php-container/actions/workflows/php7.3.yml) | ![Tests](https://img.shields.io/badge/tests-28%20passed-brightgreen) | PHP 7.3.33 + Nginx + Composer 2 + `install-php-extensions` + `install-headless` (~198 MB) |

---

## 🧩 Built-in Extensions and Packages (`8.3`, `8.4`, `8.5`)

- **Default PHP extensions installed via native `apk`:**
  `bcmath`, `ctype`, `curl`, `dom`, `fileinfo`, `ftp`, `gd`, `iconv`, `intl`, `json`, `mbstring`, `mysqlnd`, `openssl`, `pcntl`, `pdo`, `pdo_mysql`, `pear`, `phar`, `posix`, `redis` (`php-pecl-redis`), `session`, `simplexml`, `sockets`, `sodium`, `tokenizer`, `xml`, `xmlreader`, `xmlwriter`, `Zend OPcache`, `zip`, `zlib`.
- **System packages (Alpine Linux):**
  `nginx` (mainline), `curl`, `ca-certificates`, `s6-overlay`.
  - On `-headless` tags: `xvfb`, `fontconfig`, `dbus`, `libxrender`, `font-freefont` / `ttf-freefont`.

---

## 🛠️ Extension, Headless, Octane & Security Hardening Helpers

All images (`7.3` through `8.5`) provide the following utilities in `/usr/local/bin/`:
- **`install-headless`**: Available in **all versions (`7.3` through `8.5`)**. Installs `xvfb`, `fontconfig`, `dbus`, `libxrender`, and `ttf-freefont` on demand for headless browser automation (Puppeteer, Browsershot, Chrome Headless).
- **`install-php-extensions`** (and its alias **`docker-php-ext-install`**): Available in **all versions (`7.3` through `8.5`)**. Installs, compiles, and enables one or more extensions (via PECL, official Alpine packages, PHP core sources, or Oracle Instant Client) and cleans up all temporary build dependencies and the Alpine `apk` package manager once finished.
- **`docker-php-ext-enable`**: Available in **all versions (`7.3` through `8.5`)**. Enables an already-compiled `.so` module by creating the corresponding `.ini` file in PHP's `conf.d` directory.
- **`octane-install`** (and its alias **`install-octane`**): Available in **`8.3`, `8.4`, and `8.5`**. Installs and enables `swoole`, `pcntl`, and `posix`, configures the `s6-overlay` Octane service (`/etc/services.d/octane/run`), updates `/etc/nginx/nginx.conf` to reverse-proxy requests to Octane on port `8000`, and purges `apk` after compilation.
- **Runtime Hardening (`s6-overlay` `cont-init.d`):** All images (`7.3`, `7.4`, `8.0`, `8.1`, `8.2`, `8.3`, `8.4`, `8.5`) automatically purge `apk-tools` and remove `/sbin/apk`, `/usr/sbin/apk`, `/etc/apk`, `/lib/apk`, `/usr/share/apk`, and `/var/cache/apk` during container startup (`/etc/cont-init.d/00-remove-apk.sh`). This allows developers to run `install-php-extensions`, `octane-install`, or `apk add` during `docker build`, while ensuring running pods do not have the `apk` binary available.

### Examples of extensions supported by `install-php-extensions`:
- **Oracle (`oci8` and `pdo_oci`):** Automatically downloads and configures Oracle Instant Client in `/opt/oracle/instantclient` and compiles the version-matched `oci8` extension (`oci8-2.2.0` on PHP 7.x, `oci8-3.0.1` on PHP 8.0, `oci8-3.2.1` on PHP 8.1/8.2, and latest `oci8` on PHP 8.3/8.4/8.5):
  ```dockerfile
  RUN install-php-extensions oci8
  # or with PDO_OCI:
  RUN install-php-extensions oci8 pdo_oci
  ```
- **Other extensions (Core, Alpine, or PECL):**
  ```dockerfile
  RUN install-php-extensions soap xsl pgsql pdo_pgsql ldap gmp gettext bz2 calendar
  RUN install-php-extensions xdebug imagick swoole amqp apcu mongodb
  ```

---

## ⚙️ Environment Variables (`.env`) & GitHub Actions CI/CD

All versions (`7.3` through `8.5`) use two levels of `.env` configuration for standardized maintenance and tagging:

1. **Root `.env` (or GitHub Secrets in CI)** — defines the Docker Hub repository and image name:
   - **Local development:** Copy `.env.example` to `.env` in the repository root (ignored by git via `.gitignore`):
     ```bash
     cp .env.example .env
     ```
     ```env
     REPOSITORY=renatobalbino
     IMAGE=php
     ```
   - **GitHub Actions CI (`.github/workflows/`):**
     Each PHP version has its own dedicated workflow (`php8.5.yml`, `php8.4.yml`, `php8.3.yml`, `php8.2.yml`, `php8.1.yml`, `php8.0.yml`, `php7.4.yml`, `php7.3.yml`) calling the shared reusable workflow `_build-version.yml`, plus `docker-image.yml` for full matrix builds. This provides individual live GitHub status badges for every version in `readme.md`:
     - `secrets.REPOSITORY` (fallback: `secrets.DOCKERHUB_USERNAME`)
     - `secrets.IMAGE` (fallback: `php`)
     - `secrets.DOCKERHUB_USERNAME` & `secrets.DOCKERHUB_TOKEN` (for Docker Hub authentication)
2. **Version-level `.env`** (e.g., `php8.5/.env`, `php8.4/.env`, `php8.3/.env`, `php7.4/.env`) — defines the specific image tag for that variant:
   ```env
   TAG=8.5
   ```

---

## 🧪 Running Automated Tests (Without pushing to Docker Hub)

The repository provides an automated test suite at `tests/test-images.sh` which:
1. Builds the image locally (or tests a pre-built image).
2. Prints a complete inventory of installed versions (Alpine, Kernel, PHP CLI, PHP-FPM, Nginx, Composer, OpenSSL, cURL, `apk` packages, and PHP extensions).
3. Validates the availability of helper scripts (`install-php-extensions`, `docker-php-ext-enable`, `octane-install`, `install-headless`), all required extensions, Alpine packages, and `php.ini` directives (`expose_php = Off`).
4. Starts a temporary container to verify Nginx + PHP-FPM HTTP responses (`GET /`, security headers, hidden `X-Powered-By`, `/ping`, `/status`), and confirms that `apk` has been completely removed inside the running pod.
5. Automatically updates the **Test Suite** badges in `readme.md`.

```bash
# Test all versions (7.3 through 8.5) and update readme.md status badges
./tests/test-images.sh all
# or
./build-all.sh --no-push

# Test modern versions (php8.3, php8.4, php8.5)
./tests/test-images.sh modern

# Test a specific version (8.5, 8.4, 8.3, 8.2, 8.1, 8.0, 7.4, 7.3)
./tests/test-images.sh 8.5
./tests/test-images.sh 8.4
./tests/test-images.sh 8.3
./tests/test-images.sh 8.2
./tests/test-images.sh 8.1
./tests/test-images.sh 7.4
```

---

## 🚀 Building and Publishing to Docker Hub

The root `./build.sh` and `./build-all.sh` scripts build the targeted version(s) using the `.env` files, **automatically run the test suite** (updating the status flags in `readme.md`), and push (`docker push`) the image(s) to Docker Hub only if 100% of the tests pass. If any test fails, the push is aborted.

```bash
# Build + Test + Update readme.md + Push ALL versions (7.3 through 8.5)
./build-all.sh
# or
./build.sh all

# Build + Test + Update readme.md locally for ALL versions WITHOUT pushing to Docker Hub
./build-all.sh --no-push

# Build + Test + Push PHP 8.5 (default)
./build.sh
# or
./build.sh 8.5

# Build + Test + Push specific versions
./build.sh 8.4
./build.sh 8.3
./build.sh 8.2
./build.sh 8.1
./build.sh 8.0
./build.sh 7.4
./build.sh 7.3
```

---

## 💻 Usage in Microservices (Laravel / Lumen)

### 1. Standard microservice:
```dockerfile
FROM renatobalbino/php:8.4

WORKDIR /var/www/html
COPY . .

RUN composer install --no-dev --ignore-platform-reqs --optimize-autoloader
```

### 2. Microservice requiring Headless Browser (Puppeteer / Browsershot / Chrome Headless):
```dockerfile
# Use the pre-built headless variant (PHP 8.0+)
FROM renatobalbino/php:8.4-headless

WORKDIR /var/www/html
COPY . .

RUN composer install --no-dev --ignore-platform-reqs --optimize-autoloader
```

> **Tip:** You can also install headless tools on demand in any version (`7.3` through `8.5`) using the built-in helper:
> ```dockerfile
> FROM renatobalbino/php:8.4
> RUN install-headless
> ```

### 3. Microservice requiring Oracle (`oci8`) or additional custom extensions:
```dockerfile
FROM renatobalbino/php:8.3

# Installs Oracle Instant Client + oci8 extension (and/or soap, xdebug, pgsql, etc.)
RUN install-php-extensions oci8

WORKDIR /var/www/html
COPY . .

RUN composer install --no-dev --ignore-platform-reqs --optimize-autoloader
```

### 4. Microservice with Laravel Octane (Swoole):
```dockerfile
FROM renatobalbino/php:8.4

# Installs Swoole + pcntl + posix, configures Nginx reverse proxy (port 8000) and s6-overlay Octane service
RUN octane-install

WORKDIR /var/www/html
COPY . .

RUN composer install --no-dev --ignore-platform-reqs --optimize-autoloader
```

### Running locally with volume mounting:
```bash
cd your_project/
docker run -d -p 8000:80 -v $(pwd):/var/www/html renatobalbino/php:8.4
```

---

## ➕ Creating a New Version in the Future

1. Duplicate the latest version directory (e.g., `cp -r php8.5 php8.6`).
2. Edit `php8.6/.env` to update the `TAG` variable (e.g., `TAG=8.6`).
3. Update `php8.6/Dockerfile` and `php8.6/config/boostrap.sh` with the target Alpine package version (`PHP_VERSION=86`).
4. Run `./tests/test-images.sh php8.6` to validate locally or `./build.sh 8.6` to test and push.
