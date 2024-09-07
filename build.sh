if [ -z $1 ]
then
    PHP_VERSION=8.2
else
    PHP_VERSION=$1
fi

echo "### BUILDING PHP VERSION $PHP_VERSION ###"
sleep 1s
cd php$PHP_VERSION/ && sh scripts/build.sh