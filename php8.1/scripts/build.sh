REPOSITORY=leandreaci
IMAGE=php
TAG=8.1
TAG_DEV=${TAG}-dev

docker build --no-cache -t $IMAGE:$TAG --target production .
docker tag $IMAGE:$TAG $REPOSITORY/$IMAGE:$TAG
docker tag $IMAGE:$TAG $REPOSITORY/$IMAGE:latest
docker push $REPOSITORY/$IMAGE:$TAG
docker push $REPOSITORY/$IMAGE:latest

docker build --no-cache -t $IMAGE:$TAG_DEV --target development .
docker tag $IMAGE:$TAG_DEV $REPOSITORY/$IMAGE:$TAG_DEV
docker push $REPOSITORY/$IMAGE:$TAG_DEV