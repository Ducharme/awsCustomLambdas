#!/bin/sh

IMAGE_REPO_NAME=my-hello-lambda
IMAGE_TAG=latest

RIE_PKG=https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie
RIE_DIR=~/.aws-lambda-rie

# https://docs.aws.amazon.com/lambda/latest/dg/nodejs-image.html

if [ ! -d "$RIE_DIR" ]; then
    mkdir -p $RIE_DIR && \
        curl -Lo $RIE_DIR/aws-lambda-rie $RIE_PKG && \
        chmod +x $RIE_DIR/aws-lambda-rie
fi

docker run -d -v $RIE_DIR:/aws-lambda -p 9000:8080 \
    --entrypoint /aws-lambda/aws-lambda-rie \
    $IMAGE_REPO_NAME:$IMAGE_TAG /usr/local/bin/npx aws-lambda-ric index.handler

sleep 5 && curl "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{"mode": "my-value"}'

echo ""
CONTAINER_ID=$(docker ps | grep $IMAGE_REPO_NAME:$IMAGE_TAG | cut -d ' ' -f1)
docker kill $CONTAINER_ID
