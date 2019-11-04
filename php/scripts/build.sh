REPOSITORY=leandreaci
IMAGE=php7.3
TAG=0.2

docker build -t $IMAGE:$TAG .
docker tag $IMAGE:$TAG $REPOSITORY/$IMAGE:$TAG
docker tag $IMAGE:$TAG $REPOSITORY/$IMAGE:latest
docker push $REPOSITORY/$IMAGE:$TAG
docker push $REPOSITORY/$IMAGE:latest