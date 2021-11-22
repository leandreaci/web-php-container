FROM alpine:3.14

COPY /config/boostrap.sh \
    /config/oci8.sh \
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


#Copy FPM service script
COPY /config/start-php-fpm7.sh /etc/services.d/php-fpm8/run
RUN chmod 755 /etc/services.d/php-fpm8/run

#RUN wget http://pear.php.net/go-pear.phar
#RUN /usr/bin/php8 go-pear.phar

#RUN sh oci8.sh

#Copy NGINX service script
COPY /config/start-nginx.sh /etc/services.d/nginx/run
RUN chmod 755 /etc/services.d/nginx/run

COPY /config/php.ini /etc/php7/

WORKDIR /var/www/html 