FROM alpine:3.13
USER root

COPY /config/boostrap.sh \
    /config/oci8.sh \
    /uploads/s6-overlay-amd64.tar.gz \
    /uploads/oci8-2.2.0.tgz \
    /config/www.conf \
    /config/nginx.conf \
    /config/start-nginx.sh \
    /config/start-php-fpm7.sh \
    tmp/ 
    
WORKDIR /tmp/ 
RUN sh boostrap.sh

ENTRYPOINT ["/init"]
CMD []

#Copy FPM service script
COPY /config/start-php-fpm7.sh /etc/services.d/php-fpm7/run
RUN chmod 755 /etc/services.d/php-fpm7/run

#Copy NGINX service script
COPY /config/start-nginx.sh /etc/services.d/nginx/run
RUN chmod 755 /etc/services.d/nginx/run

COPY /config/php.ini /etc/php7/

WORKDIR /var/www/html 