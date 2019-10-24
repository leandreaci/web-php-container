REPOSITORY=leandreaci
IMAGE=php7.3
TAG=0.1

docker build -t $IMAGE:$TAG .
docker tag $IMAGE:$TAG $REPOSITORY/$IMAGE:$TAG
docker push $REPOSITORY/$IMAGE:$TAG