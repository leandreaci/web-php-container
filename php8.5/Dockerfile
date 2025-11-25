FROM alpine:edge
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

ENV PHP_VERSION=85

COPY /config/boostrap.sh \
    /uploads/s6-overlay-amd64.tar.gz \
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

COPY /config/php.ini /etc/php84/

WORKDIR /var/www/html
