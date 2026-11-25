#!/bin/sh
set -e

PHP_VERSION=83

gunzip -c /tmp/s6-overlay-amd64.tar.gz | tar -xf - -C /

# Essentials & PHP packages
apk upgrade --update-cache --available
apk add --no-cache \
    curl \
    nginx \
    php$PHP_VERSION \
    php$PHP_VERSION-common \
    php$PHP_VERSION-bcmath \
    php$PHP_VERSION-ctype \
    php$PHP_VERSION-curl \
    php$PHP_VERSION-dev \
    php$PHP_VERSION-dom \
    php$PHP_VERSION-fileinfo \
    php$PHP_VERSION-fpm \
    php$PHP_VERSION-ftp \
    php$PHP_VERSION-gd \
    php$PHP_VERSION-iconv \
    php$PHP_VERSION-intl \
    php$PHP_VERSION-json \
    php$PHP_VERSION-mbstring \
    php$PHP_VERSION-mysqlnd \
    php$PHP_VERSION-opcache \
    php$PHP_VERSION-openssl \
    php$PHP_VERSION-pcntl \
    php$PHP_VERSION-pdo \
    php$PHP_VERSION-pdo_mysql \
    php$PHP_VERSION-pear \
    php$PHP_VERSION-phar \
    php$PHP_VERSION-posix \
    php$PHP_VERSION-pecl-redis \
    php$PHP_VERSION-session \
    php$PHP_VERSION-simplexml \
    php$PHP_VERSION-sockets \
    php$PHP_VERSION-sodium \
    php$PHP_VERSION-tokenizer \
    php$PHP_VERSION-xml \
    php$PHP_VERSION-xmlreader \
    php$PHP_VERSION-xmlwriter \
    php$PHP_VERSION-zip \
    php$PHP_VERSION-zlib

ln -sf /usr/bin/php$PHP_VERSION /usr/bin/php
ln -sf /usr/sbin/php-fpm$PHP_VERSION /usr/sbin/php-fpm

# Nginx & PHP-FPM config
mkdir -p /var/www/html/public/
mv /tmp/nginx.conf /etc/nginx/
mv /tmp/www.conf /etc/php$PHP_VERSION/php-fpm.d/www.conf

echo "<?php phpinfo(); ?>" > /var/www/html/public/index.php

# Create s6-overlay cont-init.d hook to remove apk at container startup
mkdir -p /etc/cont-init.d
cat << 'EOF' > /etc/cont-init.d/00-remove-apk.sh
#!/usr/bin/with-contenv sh
apk del --purge apk-tools 2>/dev/null || true
rm -rf /sbin/apk /usr/sbin/apk /etc/apk /lib/apk /usr/share/apk /var/cache/apk
EOF
chmod 755 /etc/cont-init.d/00-remove-apk.sh

# Cleanup
rm -rf /tmp/* /var/cache/apk/*
