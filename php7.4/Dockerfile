# Stage 1: Runtime base image
FROM alpine:3.14 AS base

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

COPY /config/install-php-extensions /usr/local/bin/install-php-extensions
COPY /config/docker-php-ext-enable /usr/local/bin/docker-php-ext-enable
COPY /config/install-headless /usr/local/bin/install-headless
RUN chmod +x /usr/local/bin/install-php-extensions /usr/local/bin/docker-php-ext-enable /usr/local/bin/install-headless \
    && ln -sf /usr/local/bin/install-php-extensions /usr/local/bin/docker-php-ext-install

COPY /config/boostrap.sh \
    /uploads/s6-overlay-amd64.tar.gz \
    /config/www.conf \
    /config/nginx.conf \
    /config/start-nginx.sh \
    /config/start-php-fpm7.sh \
    tmp/ 
    
WORKDIR /tmp/ 
RUN sh boostrap.sh

ENTRYPOINT ["/init"]
CMD []

# Copy FPM service script
COPY /config/start-php-fpm7.sh /etc/services.d/php-fpm7/run
RUN chmod 755 /etc/services.d/php-fpm7/run

# Copy NGINX service script
COPY /config/start-nginx.sh /etc/services.d/nginx/run
RUN chmod 755 /etc/services.d/nginx/run

COPY /config/php.ini /etc/php7/

WORKDIR /var/www/html
