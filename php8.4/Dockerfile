FROM alpine:3.24.1
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

ENV PHP_VERSION=84

COPY /config/install-php-extensions /usr/local/bin/install-php-extensions
COPY /config/docker-php-ext-enable /usr/local/bin/docker-php-ext-enable
RUN chmod +x /usr/local/bin/install-php-extensions /usr/local/bin/docker-php-ext-enable \
    && ln -sf /usr/local/bin/install-php-extensions /usr/local/bin/docker-php-ext-install

COPY /config/boostrap.sh \
    /uploads/s6-overlay-amd64.tar.gz \
    /config/www.conf \
    /config/nginx.conf \
    /config/start-nginx.sh \
    /config/start-php-fpm.sh \
    /tmp/

WORKDIR /tmp/
RUN sh boostrap.sh

ENTRYPOINT ["/init"]
CMD []

#Copy FPM service script
COPY /config/start-php-fpm.sh /etc/services.d/php-fpm/run
RUN chmod 755 /etc/services.d/php-fpm/run

#Copy NGINX service script
COPY /config/start-nginx.sh /etc/services.d/nginx/run
RUN chmod 755 /etc/services.d/nginx/run

COPY /config/php.ini /usr/local/etc/php/php.ini

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
