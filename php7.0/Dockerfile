FROM alpine:3.7
ADD https://repos.php.earth/alpine/phpearth.rsa.pub /etc/apk/keys/phpearth.rsa.pub
COPY /config/boostrap.sh /uploads/s6-overlay-amd64.tar.gz /config/nginx.conf /config/start-nginx.sh /config/start-php-fpm7.sh tmp/ 
WORKDIR /tmp/ 
RUN sh boostrap.sh

ENTRYPOINT ["/init"]
CMD []

#Copy NGINX service script
COPY /config/start-nginx.sh /etc/services.d/nginx/run
RUN chmod 755 /etc/services.d/nginx/run

#Copy FPM service script
COPY /config/start-php-fpm7.sh /etc/services.d/php-fpm7/run
RUN chmod 755 /etc/services.d/php-fpm7/run