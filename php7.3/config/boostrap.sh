#!bin/sh

PHP_VERSION=7.3
gunzip -c /tmp/s6-overlay-amd64.tar.gz | tar -xf - -C /

echo "https://repos.php.earth/alpine/v3.9" >> /etc/apk/repositories

#Essentials
apk update && apk upgrade
apk add curl
apk add nginx
apk add php$PHP_VERSION 
apk add php$PHP_VERSION-fpm 
apk add php$PHP_VERSION-opcache 
apk add php$PHP_VERSION-json 
apk add php$PHP_VERSION-mbstring  
apk add php$PHP_VERSION-session 
apk add php$PHP_VERSION-ctype  
apk add php$PHP_VERSION-zlib
apk add php$PHP_VERSION-curl
apk add php$PHP_VERSION-openssl
apk add php$PHP_VERSION-mysqlnd
apk add php$PHP_VERSION-mysqli
apk add php$PHP_VERSION-pdo
apk add php$PHP_VERSION-pdo_mysql
apk add php$PHP_VERSION-tokenizer
apk add php$PHP_VERSION-dom
apk add php$PHP_VERSION-dev 
apk add php$PHP_VERSION-pear
apk add php$PHP_VERSION-sockets
apk add php$PHP_VERSION-fileinfo
apk add php$PHP_VERSION-xml
apk add php$PHP_VERSION-xmlwriter
apk add php$PHP_VERSION-simplexml
apk add composer

#Nginx
mkdir /run/nginx
mkdir -p /var/www/html/

mv /tmp/nginx.conf /etc/nginx/
mv /tmp/www.conf /etc/php/$PHP_VERSION/php-fpm.d/www.conf
mkdir -p /var/www/html/public/

echo "<?php phpinfo(); ?>" > /var/www/html/public/index.php

rm -r /tmp/*
