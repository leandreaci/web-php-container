#!bin/sh

gunzip -c /tmp/s6-overlay-amd64.tar.gz | tar -xf - -C /

echo "https://repos.php.earth/alpine/v3.7" >> /etc/apk/repositories
apk add --no-cache php7.0

apk update && apk upgrade
apk add curl
apk add nginx
apk add php7.0 php7.0-fpm 
apk add php7.0-opcache 
apk add php7.0-json php7.0-mbstring 
apk add php7.0-session php7.0-ctype 
apk add php7.0-zlib 
apk add php7.0-curl php7.0-mcrypt
apk add php7.0-openssl
apk add php7.0-mysqlnd
apk add php7.0-mysqli
apk add php7.0-pdo
apk add php7.0-pdo_mysql
apk add php7.0-tokenizer
apk add php7.0-xml
apk add php7.0-dom
mkdir /run/nginx
mkdir -p /var/www/html/

mv /tmp/nginx.conf /etc/nginx/
mkdir -p /var/www/html/public/

echo "<?php phpinfo(); ?>" > /var/www/html/public/index.php
