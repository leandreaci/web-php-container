#!/bin/sh
set -e

gunzip -c /tmp/s6-overlay-amd64.tar.gz | tar -xf - -C /

# Essentials
apk upgrade --update-cache --available
apk add --no-cache curl ca-certificates

# Add official NGINX repo for latest security fixes (CVE-2026-1642, CVE-2025-53859)
ALPINE_VERSION=$(cut -d. -f1,2 /etc/alpine-release)
curl -fsSL -o /etc/apk/keys/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub
printf "https://nginx.org/packages/mainline/alpine/v%s/main\n" "$ALPINE_VERSION" >> /etc/apk/repositories
apk update
apk add --no-cache nginx

# Install PHP extensions & Oracle OCI8
install-php-extensions \
    opcache \
    pdo_mysql \
    mysqli \
    sockets \
    gd \
    redis \
    oci8

sh /tmp/oci8.sh

# Nginx & PHP-FPM configuration
mkdir -p /var/www/html/public/
mv /tmp/nginx.conf /etc/nginx/
rm -f /usr/local/etc/php-fpm.d/zz-docker.conf
mv /tmp/www.conf /usr/local/etc/php-fpm.d/www.conf

echo "<?php phpinfo(); ?>" > /var/www/html/public/index.php

rm -rf /tmp/*

