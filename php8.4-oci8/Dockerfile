FROM alpine:3.23

ONBUILD ARG INSTALL_XDEBUG
ENV INSTALL_XDEBUG=${INSTALL_XDEBUG:-false}
ENV PHP_VERSION=84

COPY /config/boostrap.sh \
    /config/oci8.sh \
    /uploads/* \
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
    && apk add php$PHP_VERSION-dev php$PHP_VERSION-xdebug \
    && cp /tmp/xdebug.ini /etc/php$PHP_VERSION/conf.d/50_xdebug.ini \
;fi

ENTRYPOINT ["/init"]
CMD []

#Copy FPM service script3.12
COPY /config/start-php-fpm.sh /etc/services.d/php-fpm$PHP_VERSION/run
RUN chmod 755 /etc/services.d/php-fpm$PHP_VERSION/run

#Copy NGINX service script
COPY /config/start-nginx.sh /etc/services.d/nginx/run
RUN chmod 755 /etc/services.d/nginx/run

COPY /config/php.ini /etc/php$PHP_VERSION/

RUN chmod -R 755 /var/lib/nginx

WORKDIR /var/www/html 
