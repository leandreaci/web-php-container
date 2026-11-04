#!bin/sh

PHP_VERSION=82

gunzip -c /tmp/s6-overlay-amd64.tar.gz | tar -xf - -C /

#Essentials
apk upgrade --update-cache --available
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

ln -s /usr/bin/php82 /usr/bin/php

#Nginx
mkdir -p /var/www/html/
mv /tmp/nginx.conf /etc/nginx/
mv /tmp/www.conf /etc/php$PHP_VERSION/php-fpm.d/www.conf
mkdir -p /var/www/html/public/

echo "<?php phpinfo(); ?>" > /var/www/html/public/index.php

# Ensure composer permissions
chmod +x /usr/local/bin/composer || true

# Create s6-overlay cont-init.d hook to remove apk at container startup (leaving apk available for child Dockerfiles during build)
mkdir -p /etc/cont-init.d
cat << 'EOF' > /etc/cont-init.d/00-remove-apk.sh
#!/usr/bin/with-contenv sh
apk del --purge apk-tools 2>/dev/null || true
rm -rf /sbin/apk /usr/sbin/apk /etc/apk /lib/apk /usr/share/apk /var/cache/apk
EOF
chmod 755 /etc/cont-init.d/00-remove-apk.sh

#rm -r /tmp/*
rm /tmp/s6-overlay-amd64.tar.gz
