REPOSITORY=leandreaci
IMAGE=php
TAG=7.2

docker build -t $IMAGE:$TAG .
docker tag $IMAGE:$TAG $REPOSITORY/$IMAGE:$TAG
docker push $REPOSITORY/$IMAGE:$TAG