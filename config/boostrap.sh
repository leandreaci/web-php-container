#!bin/sh

gunzip -c /tmp/s6-overlay-amd64.tar.gz | tar -xf - -C /

apk update && apk upgrade
apk add curl
apk add nginx
apk add php7 php7-fpm php7-opcache
apk add php7-gd php7-mysqli php7-zlib php7-curl
mkdir /run/nginx
mkdir -p /var/www/html/

mv /tmp/nginx.conf /etc/nginx/

echo "<?php phpinfo(); ?>" > /var/www/html/index.php
