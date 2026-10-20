FROM alpine:3.24.1
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

ENV PHP_VERSION=85

COPY /config/boostrap.sh \
    /config/oci8.sh \
    /uploads/* \
    /config/www.conf \
    /config/nginx.conf \
    /config/start-nginx.sh \
    /config/start-php-fpm.sh \
    tmp/
    
WORKDIR /tmp/ 
RUN sh boostrap.sh

ENTRYPOINT ["/init"]
CMD []

#Copy FPM service script3.12
COPY /config/start-php-fpm.sh /etc/services.d/php-fpm$PHP_VERSION/run
RUN chmod 755 /etc/services.d/php-fpm$PHP_VERSION/run

#Copy NGINX service script
COPY /config/start-nginx.sh /etc/services.d/nginx/run
RUN chmod 755 /etc/services.d/nginx/run

COPY /config/php.ini /etc/php$PHP_VERSION/

RUN mkdir -p /var/lib/nginx \
             /var/lib/nginx/tmp/client_body \
             /var/lib/nginx/tmp/fastcgi \
             /var/lib/nginx/tmp/proxy \
             /var/lib/nginx/tmp/uwsgi \
             /var/lib/nginx/tmp/scgi \
             /var/log/nginx \
             /run/nginx \
    && chown -R nobody:nobody /var/lib/nginx /var/log/nginx /run/nginx \
    && chmod -R 770 /var/lib/nginx/tmp

WORKDIR /var/www/html 
