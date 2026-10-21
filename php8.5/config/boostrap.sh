#!/bin/sh
set -e

PHP_RELEASE="${PHP_RELEASE:-8.5.12}"

gunzip -c /tmp/s6-overlay-amd64.tar.gz | tar -xf - -C /

# Essentials & runtime libraries
apk upgrade --update-cache --available
apk add --no-cache \
    curl \
    ca-certificates \
    libgcc \
    libstdc++ \
    libxml2 \
    oniguruma \
    libcurl \
    openssl \
    libsodium \
    sqlite-libs \
    zlib \
    libpng \
    libjpeg-turbo \
    freetype \
    libwebp \
    icu-libs \
    libzip \
    readline \
    xvfb \
    ttf-freefont \
    fontconfig \
    dbus \
    libxrender

# Add official NGINX repo for latest security fixes (CVE-2026-1642, CVE-2025-53859)
ALPINE_VERSION=$(cut -d. -f1,2 /etc/alpine-release)
curl -fsSL -o /etc/apk/keys/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub
if ! curl -fsSLI "https://nginx.org/packages/mainline/alpine/v${ALPINE_VERSION}/main/x86_64/APKINDEX.tar.gz" >/dev/null 2>&1; then
    ALPINE_VERSION="3.23"
fi
printf "https://nginx.org/packages/mainline/alpine/v%s/main\n" "$ALPINE_VERSION" >> /etc/apk/repositories
apk update
apk add --no-cache nginx

# Install build dependencies in virtual package .build-deps
apk add --no-cache --virtual .build-deps \
    autoconf \
    bison \
    build-base \
    re2c \
    pkgconfig \
    linux-headers \
    libxml2-dev \
    oniguruma-dev \
    curl-dev \
    openssl-dev \
    libsodium-dev \
    sqlite-dev \
    zlib-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libwebp-dev \
    icu-dev \
    libzip-dev \
    readline-dev \
    xz

# Download and compile latest official PHP 8.5 source from php.net
mkdir -p /usr/src/php /usr/local/etc/php/conf.d /usr/local/etc/php-fpm.d
curl -fsSL "https://www.php.net/distributions/php-${PHP_RELEASE}.tar.xz" -o /tmp/php.tar.xz
tar -xJf /tmp/php.tar.xz -C /usr/src/php --strip-components=1

cd /usr/src/php
./configure \
    --prefix=/usr/local \
    --with-config-file-path=/usr/local/etc/php \
    --with-config-file-scan-dir=/usr/local/etc/php/conf.d \
    --enable-fpm \
    --with-fpm-user=root \
    --with-fpm-group=root \
    --disable-cgi \
    --enable-mbstring \
    --enable-mysqlnd \
    --enable-opcache \
    --enable-sockets \
    --enable-pcntl \
    --enable-bcmath \
    --enable-exif \
    --enable-ftp \
    --enable-intl \
    --with-zip \
    --with-curl \
    --with-openssl \
    --with-zlib \
    --with-sodium \
    --with-mysqli=mysqlnd \
    --with-pdo-mysql=mysqlnd \
    --enable-gd \
    --with-jpeg \
    --with-webp \
    --with-freetype \
    --with-pear

make -j"$(nproc)"
make install

# Symlink binaries to /usr/bin for full compatibility
ln -sf /usr/local/bin/php /usr/bin/php
ln -sf /usr/local/bin/phpize /usr/bin/phpize
ln -sf /usr/local/bin/php-config /usr/bin/php-config
ln -sf /usr/local/bin/pecl /usr/bin/pecl
ln -sf /usr/local/sbin/php-fpm /usr/sbin/php-fpm

# Provide default php-fpm.conf that includes /usr/local/etc/php-fpm.d/*.conf
cp /usr/local/etc/php-fpm.conf.default /usr/local/etc/php-fpm.conf

# Install Redis extension via PECL
export PHP_AUTOCONF=/usr/bin/autoconf
export PHP_AUTOHEADER=/usr/bin/autoheader
/usr/local/bin/pecl channel-update pecl.php.net
printf "\n" | /usr/local/bin/pecl install redis
echo "extension=redis.so" > /usr/local/etc/php/conf.d/20_redis.ini

# Clean up source and build dependencies
cd /tmp
rm -rf /usr/src/php /tmp/php.tar.xz
apk del .build-deps

# Nginx & PHP-FPM configuration
mkdir -p /var/www/html/public/
mv /tmp/nginx.conf /etc/nginx/
mv /tmp/www.conf /usr/local/etc/php-fpm.d/www.conf

echo "<?php phpinfo(); ?>" > /var/www/html/public/index.php

rm -rf /tmp/*
