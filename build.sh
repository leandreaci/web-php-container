if [ -z $1 ]
then
    PHP_VERSION=7.3
else
    PHP_VERSION=$1
fi

echo "### BUILDING PHP VERSION $PHP_VERSION ###"
sleep 1s
cd php$PHP_VERSION/ && sh scripts/build.sh
docker run -it -p 80:80 web-php-$PHP_VERSION /bin/sh