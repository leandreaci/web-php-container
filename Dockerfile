FROM alpine
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.21.8.0/s6-overlay-amd64.tar.gz /tmp/
RUN gunzip -c /tmp/s6-overlay-amd64.tar.gz | tar -xf - -C /
COPY boostrap.sh tmp/ 
WORKDIR /tmp/ 
RUN sh boostrap.sh

ENTRYPOINT ["/init"]
CMD []

COPY nginx.conf /etc/nginx/

# Copy NGINX service script
COPY start-nginx.sh /etc/services.d/nginx/run
RUN chmod 755 /etc/services.d/nginx/run

# Copy FPM service script
COPY start-php-fpm7.sh /etc/services.d/php-fpm7/run
RUN chmod 755 /etc/services.d/php-fpm7/run