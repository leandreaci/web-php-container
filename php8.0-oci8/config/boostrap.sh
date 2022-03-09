#!bin/sh

PHP_VERSION=8
gunzip -c /tmp/s6-overlay-amd64.tar.gz | tar -xf - -C /

#Essentials
apk upgrade --update-cache --available
apk add musl-dev libaio libnsl autoconf libc6-compat gcompat && apk add --update make
apk add gcc
apk add pcre
apk add curl
apk add nginx
apk add php$PHP_VERSION 
apk add php$PHP_VERSION-common
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
apk add php$PHP_VERSION-pdo
apk add php$PHP_VERSION-pdo_mysql
apk add php$PHP_VERSION-tokenizer
apk add php$PHP_VERSION-xml
apk add php$PHP_VERSION-dom
apk add php$PHP_VERSION-dev 
apk add php$PHP_VERSION-pear
apk add php$PHP_VERSION-sockets
apk add php$PHP_VERSION-fileinfo
apk add php$PHP_VERSION-xmlwriter
apk add php$PHP_VERSION-simplexml
apk add php$PHP_VERSION-phar
apk add composer

ln -s /usr/bin/php8 /usr/bin/php


mv composer.phar /usr/local/bin/composer

sh /tmp/oci8.sh

#Nginx
#mkdir /run/nginx
mkdir -p /var/www/html/

mv /tmp/nginx.conf /etc/nginx/
mv /tmp/www.conf /etc/php8/php-fpm.d/www.conf
mkdir -p /var/www/html/public/

echo "<?php phpinfo(); ?>" > /var/www/html/public/index.php

rm -r /tmp/*
