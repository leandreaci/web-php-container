# Stage 1: Runtime base image
FROM alpine:3.21 AS base

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

ONBUILD ARG INSTALL_XDEBUG
ENV INSTALL_XDEBUG=${INSTALL_XDEBUG:-false}

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
    /config/start-php-fpm.sh \
    /config/xdebug.ini \
    tmp/
    
WORKDIR /tmp/ 
RUN sh boostrap.sh

ONBUILD ARG INSTALL_XDEBUG
ARG INSTALL_XDEBUG=${INSTALL_XDEBUG:-false}
RUN if [ "$INSTALL_XDEBUG" = true ]; then \
    echo "Install Xdebug\n" \
    && apk add php82-dev php82-xdebug \
    && cp /tmp/xdebug.ini /etc/php82/conf.d/50_xdebug.ini \
;fi

ENTRYPOINT ["/init"]
CMD []

# Copy FPM service script
COPY /config/start-php-fpm.sh /etc/services.d/php-fpm82/run
RUN chmod 755 /etc/services.d/php-fpm82/run

# Copy NGINX service script
COPY /config/start-nginx.sh /etc/services.d/nginx/run
RUN chmod 755 /etc/services.d/nginx/run

COPY /config/php.ini /etc/php82/

WORKDIR /var/www/html

# Stage 2: Headless variant
FROM base AS headless
RUN install-headless
