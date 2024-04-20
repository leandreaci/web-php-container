FROM alpine:3.19.1

ONBUILD ARG INSTALL_XDEBUG
ENV INSTALL_XDEBUG=${INSTALL_XDEBUG:-false}

COPY /config/boostrap.sh \
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
    && apk add php82-dev php82-xdebug \
    && cp /tmp/xdebug.ini /etc/php82/conf.d/50_xdebug.ini \
;fi

ENTRYPOINT ["/init"]
CMD []

#Copy FPM service script3.12
COPY /config/start-php-fpm.sh /etc/services.d/php-fpm82/run
RUN chmod 755 /etc/services.d/php-fpm82/run

#Copy NGINX service script
COPY /config/start-nginx.sh /etc/services.d/nginx/run
RUN chmod 755 /etc/services.d/nginx/run

COPY /config/php.ini /etc/php81/

WORKDIR /var/www/html 
