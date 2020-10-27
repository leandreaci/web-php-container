REPOSITORY=leandreaci
IMAGE=php
TAG=7.4

docker build -t $IMAGE:$TAG .
docker tag $IMAGE:$TAG $REPOSITORY/$IMAGE:$TAG
docker tag $IMAGE:$TAG $REPOSITORY/$IMAGE:latest
# docker push $REPOSITORY/$IMAGE:$TAG
# docker push $REPOSITORY/$IMAGE:latest