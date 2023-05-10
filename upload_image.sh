#!/bin/sh

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_DEFAULT_REGION=$(aws configure get region)
IMAGE_REPO_NAME=my-ecr-repo
IMAGE_TAG=latest

aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
docker build -t $IMAGE_REPO_NAME:$IMAGE_TAG .
#docker build -t $IMAGE_REPO_NAME:${CODEBUILD_BUILD_ID} .
docker tag $IMAGE_REPO_NAME:$IMAGE_TAG $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG
#docker run -it $IMAGE_REPO_NAME:$IMAGE_TAG #docker run -it my-ecr-repo:latest