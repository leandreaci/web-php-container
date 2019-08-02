PHP_VERSION=7.3
echo "BUILDING PHP VERSION 7.3"
sleep 1s
cd php$PHP_VERSION/ && sh scripts/build.sh
docker run -it -p 80:80 web-php-$PHP_VERSION /bin/sh