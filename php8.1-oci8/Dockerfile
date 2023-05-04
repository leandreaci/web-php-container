FROM alpine:3.16 as production

COPY /config/boostrap.sh \
    /config/oci8.sh \
    /uploads/s6-overlay-amd64.tar.gz \
    /config/www.conf \
    /config/nginx.conf \
    /config/start-nginx.sh \
    /config/start-php-fpm.sh \
    tmp/ 
    
WORKDIR /tmp/ 
RUN sh boostrap.sh

#Copy FPM service script
COPY /config/start-php-fpm.sh /etc/services.d/php-fpm81/run
RUN chmod 755 /etc/services.d/php-fpm81/run

#Copy NGINX service script
COPY /config/start-nginx.sh /etc/services.d/nginx/run
RUN chmod 755 /etc/services.d/nginx/run

WORKDIR /var/www/html 

ENTRYPOINT ["/init"]
CMD []

FROM production as development

RUN apk add --no-cache --update \
    php81-xdebug; \
    { \
        echo 'zend_extension = xdebug.so'; \
        echo ''; \
        echo '[xdebug]'; \
        echo 'xdebug.mode = debug'; \
        echo 'xdebug.client_host = host.docker.internal'; \
        echo 'xdebug.client_port = 9003'; \
        echo 'xdebug.discover_client_host = true'; \
        echo 'xdebug.remote_handler = dbgp'; \
        echo 'xdebug.idekey = PHPSTORM'; \
        echo 'xdebug.show_error_trace = true'; \
        echo 'xdebug.max_nesting_level = 250'; \
        echo 'xdebug.var_display_max_depth = 10'; \
    } > /etc/php81/conf.d/50_xdebug.ini
