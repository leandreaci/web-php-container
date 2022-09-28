REPOSITORY=leandreaci
IMAGE=php
TAG=8.1-oci8

docker build --no-cache -t $IMAGE:$TAG .
docker tag $IMAGE:$TAG $REPOSITORY/$IMAGE:$TAG
docker push $REPOSITORY/$IMAGE:$TAG