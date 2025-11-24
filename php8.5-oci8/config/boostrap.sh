#!bin/sh

PHP_VERSION=85

gunzip -c /tmp/s6-overlay-amd64.tar.gz | tar -xf - -C /

#Essentials
apk upgrade --update-cache --available
apk add g++
apk add make
apk add libaio
apk add curl
apk add nginx
apk add php$PHP_VERSION 
apk add php$PHP_VERSION-common
apk add php$PHP_VERSION-ctype
apk add php$PHP_VERSION-curl
apk add php$PHP_VERSION-dev
apk add php$PHP_VERSION-dom
apk add php$PHP_VERSION-fileinfo
apk add php$PHP_VERSION-fpm
apk add php$PHP_VERSION-iconv
apk add php$PHP_VERSION-json
apk add php$PHP_VERSION-mbstring
apk add php$PHP_VERSION-mysqlnd
apk add php$PHP_VERSION-opcache
apk add php$PHP_VERSION-openssl
apk add php$PHP_VERSION-pdo
apk add php$PHP_VERSION-pdo_mysql
apk add php$PHP_VERSION-pear
apk add php$PHP_VERSION-phar
apk add php$PHP_VERSION-redis
apk add php$PHP_VERSION-session
apk add php$PHP_VERSION-simplexml
apk add php$PHP_VERSION-sockets
apk add php$PHP_VERSION-sodium
apk add php$PHP_VERSION-tokenizer
apk add php$PHP_VERSION-xml
apk add php$PHP_VERSION-xmlwriter
apk add php$PHP_VERSION-zlib

ln -s /usr/bin/php$PHP_VERSION /usr/bin/php
ln -s /usr/bin/pecl$PHP_VERSION /usr/bin/pecl

sh /tmp/oci8.sh

#Nginx
mkdir -p /var/www/html/
mv /tmp/nginx.conf /etc/nginx/
mv /tmp/www.conf /etc/php$PHP_VERSION/php-fpm.d/www.conf
mkdir -p /var/www/html/public/

echo "<?php phpinfo(); ?>" > /var/www/html/public/index.php

#install composer 2.0
chmod +x /tmp/composer.phar
mv /tmp/composer.phar /usr/local/bin/composer
composer self-update

#rm -r /tmp/*
rm /tmp/s6-overlay-amd64.tar.gz
rm /usr/bin/pecl$PHP_VERSION
rm /usr/bin/perl
apk del build-base
