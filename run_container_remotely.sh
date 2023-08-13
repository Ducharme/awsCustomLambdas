#!/bin/sh

IMAGE_REPO_NAME=my-hello-lambda
IMAGE_TAG=latest

aws lambda invoke --function-name $IMAGE_REPO_NAME ./response.json

cat ./response.json
echo ""
