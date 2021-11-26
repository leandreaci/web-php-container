#!bin/sh

PHP_VERSION=8
gunzip -c /tmp/s6-overlay-amd64.tar.gz | tar -xf - -C /

#Essentials
apk upgrade --update-cache --available
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

ln -s /usr/bin/php8 /usr/bin/php

#install composer 2.0
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '906a84df04cea2aa72f40b5f787e49f22d4c2f19492ac310e8cba5b96ac8b64115ac402c8cd292b8a03482574915d1a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"

mv composer.phar /usr/local/bin/composer

#Nginx
mkdir -p /var/www/html/

mv /tmp/nginx.conf /etc/nginx/
mv /tmp/www.conf /etc/php8/php-fpm.d/www.conf
mkdir -p /var/www/html/public/

echo "<?php phpinfo(); ?>" > /var/www/html/public/index.php

rm -r /tmp/*
