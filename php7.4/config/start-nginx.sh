#!/usr/bin/with-contenv sh
set -e;

# Garante diretórios temporários do nginx graváveis pelo worker (evita "Permission denied")
mkdir -p /var/lib/nginx/tmp/client_body /var/lib/nginx/tmp/proxy /var/lib/nginx/tmp/fastcgi \
         /var/lib/nginx/tmp/uwsgi /var/lib/nginx/tmp/scgi /var/lib/nginx/logs /run/nginx
chown -R nginx:nginx /var/lib/nginx/tmp
chmod -R 700 /var/lib/nginx/tmp

/usr/sbin/nginx -g "daemon off;"
