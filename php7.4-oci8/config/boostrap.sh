#!bin/sh

PHP_VERSION=7
gunzip -c /tmp/s6-overlay-amd64.tar.gz | tar -xf - -C /

#Essentials
sed -i -e 's/v[[:digit:]]\..*\//edge\//g' /etc/apk/repositories
apk upgrade --update-cache --available
cat /etc/alpine-release
apk add musl-dev libaio autoconf && apk add --update make
apk add gcc;
apk add pcre
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
apk add composer

# install oci8 libs & extension
mkdir -p /opt/oracle

wget https://github.com/bumpx/oracle-instantclient/raw/master/instantclient-basic-linux.x64-12.1.0.2.0.zip
wget https://github.com/bumpx/oracle-instantclient/raw/master/instantclient-sdk-linux.x64-12.1.0.2.0.zip

unzip -o ./instantclient-basic-linux.x64-12.1.0.2.0.zip -d /opt/oracle
unzip -o ./instantclient-sdk-linux.x64-12.1.0.2.0.zip -d /opt/oracle

ln -s /opt/oracle/instantclient/sqlplus /usr/bin/sqlplus
ln -s /opt/oracle/instantclient_12_1 /opt/oracle/instantclient
ln -s /opt/oracle/instantclient/libclntsh.so.12.1 /opt/oracle/instantclient/libclntsh.so
ln -s /opt/oracle/instantclient/libocci.so.12.1 /opt/oracle/instantclient/libocci.so

export LD_LIBRARY_PATH=/opt/oracle/instantclient

sh -c "echo 'instantclient,/opt/oracle/instantclient' | pecl install oci8"

# setup ld library path
sh -c "echo '/opt/oracle/instantclient' >> /etc/ld.so.conf"
ldconfig


#Nginx
mkdir /run/nginx
mkdir -p /var/www/html/

mv /tmp/nginx.conf /etc/nginx/
mv /tmp/www.conf /etc/php7/php-fpm.d/www.conf
mkdir -p /var/www/html/public/

echo "<?php phpinfo(); ?>" > /var/www/html/public/index.php

rm -r /tmp/*
