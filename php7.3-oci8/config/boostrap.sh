#!bin/sh

PHP_VERSION=7.3
gunzip -c /tmp/s6-overlay-amd64.tar.gz | tar -xf - -C /

echo "https://repos.php.earth/alpine/v3.9" >> /etc/apk/repositories

#Essentials
apk update && apk upgrade
apk add musl-dev libaio autoconf && apk add --update make
apk add gcc;
apk add curl
apk add pcre
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
apk add php$PHP_VERSION-xml
apk add php$PHP_VERSION-dom
apk add php$PHP_VERSION-dev 
apk add php$PHP_VERSION-pear
apk add libnsl

#Instant client
mkdir /opt/oracle
unzip /tmp/instantclient-basic-linux.x64-11.2.0.4.0.zip -d /opt/oracle/
unzip /tmp/instantclient-sdk-linux.x64-11.2.0.4.0.zip -d /opt/oracle/
cp /usr/lib/libnsl.so.2.0.0 /opt/oracle/instantclient_11_2/
ln -s /opt/oracle/instantclient_11_2/libclntsh.so.11.1 /opt/oracle/instantclient_11_2/libclntsh.so
ln -s /opt/oracle/instantclient_11_2/libocci.so.11.1 /opt/oracle/instantclient_11_2/libocci.so
ln -s /opt/oracle/instantclient_11_2/libnsl.so.2.0.0 /opt/oracle/instantclient_11_2/libnsl.so.1

export LD_LIBRARY_PATH=/opt/oracle/instantclient_11_2
echo "instantclient,/opt/oracle/instantclient_11_2" | pecl install oci8
echo 'extension=oci8' > /etc/php/7.3/conf.d/30-oci8.ini

#Nginx
mkdir /run/nginx
mkdir -p /var/www/html/

mv /tmp/nginx.conf /etc/nginx/
mkdir -p /var/www/html/public/

echo "<?php phpinfo(); ?>" > /var/www/html/public/index.php

rm -r /tmp/*
