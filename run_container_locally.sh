#!/bin/sh

. ./set_common_env-vars.sh


RIE_PKG=https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie
RIE_DIR=~/.aws-lambda-rie


if [ ! -d "$RIE_DIR" ]; then
    mkdir -p $RIE_DIR && \
        curl -Lo $RIE_DIR/aws-lambda-rie $RIE_PKG && \
        chmod +x $RIE_DIR/aws-lambda-rie
fi

if [ "$DOCKERFILE" = "Dockerfile_ubuntu" ]; then
    BOOTSRAP_FILE=/var/task/bootstrap
    HANDLER=function.handler
elif [ "$DOCKERFILE" = "Dockerfile_aws" ] || [ "$DOCKERFILE" = "Dockerfile_bookworm" ]; then
    BOOTSRAP_FILE="/usr/local/bin/npx aws-lambda-ric"
    HANDLER=index.handler
else
    echo "Zip file function cannot be tested locally with docker"
    exit 1
fi

# replace "-d" by "-a stderr -a stdout" to debug
echo "docker run -d -v $RIE_DIR:/aws-lambda -p 9000:8080 --entrypoint /aws-lambda/aws-lambda-rie $IMAGE_REPO_NAME:$IMAGE_TAG $BOOTSRAP_FILE $HANDLER"
docker run -d -v $RIE_DIR:/aws-lambda -p 9000:8080 --entrypoint /aws-lambda/aws-lambda-rie $IMAGE_REPO_NAME:$IMAGE_TAG $BOOTSRAP_FILE $HANDLER
#docker run -d -p 9000:8080 --entrypoint /var/task/aws-lambda-rie $IMAGE_REPO_NAME:$IMAGE_TAG ./bootstrap $HANDLER
#docker run -d -p 9000:8080 --entrypoint /var/task/aws-lambda-rie $IMAGE_REPO_NAME:$IMAGE_TAG $HANDLER


sleep 5
echo "curl -sS -L "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{"mode": "my-value"}'"
curl -sS -L "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{"mode": "my-value"}'

echo ""
CONTAINER_ID=$(docker ps | grep $IMAGE_REPO_NAME:$IMAGE_TAG | cut -d ' ' -f1)
echo "docker kill $CONTAINER_ID"
docker kill $CONTAINER_ID
