#!/bin/sh

REPOSITORY=renatobalbino
IMAGE=php
TAG=8.5

docker build --platform=linux/amd64 -t $IMAGE:$TAG .
docker tag $IMAGE:$TAG $REPOSITORY/$IMAGE:$TAG
docker tag $IMAGE:$TAG $REPOSITORY/$IMAGE:latest
docker push $REPOSITORY/$IMAGE:$TAG
docker push $REPOSITORY/$IMAGE:latest
