#!bin/sh
apk update && apk upgrade
apk add curl
apk add nginx
apk add php7 php7-fpm php7-opcache
apk add php7-gd php7-mysqli php7-zlib php7-curl
mkdir /run/nginx
mkdir -p /var/www/html/

echo "<?php phpinfo(); ?>" > /var/www/html/index.php

# echo " server {
#         listen 80 default_server;
#         listen [::]:80 default_server;

#         root /var/www/html;
#         index index.php index.html;

#         location / {
#             index index.php index.html index.htm;
#             try_files $uri $uri/ =404;
#         }

#         location ~ \.php$ {
#             fastcgi_split_path_info ^(.+\.php)(/.+)$;
#             fastcgi_pass      127.0.0.1:9000;
#             fastcgi_index index.php;
#             include fastcgi.conf;
#         }

#         # You may need this to prevent return 404 recursion.
#         location = /404.html {
#                 internal;
#         }
# } " > /etc/nginx/conf.d/default.conf
