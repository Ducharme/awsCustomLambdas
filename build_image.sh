#!/bin/sh

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_DEFAULT_REGION=$(aws configure get region)
IMAGE_REPO_NAME=my-hello-lambda
IMAGE_TAG=latest


aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com

REPO_NAMES=$(aws ecr describe-repositories | grep "repositoryName" | grep "$IMAGE_REPO_NAME" | cut -d ':' -f2 |  tr -d '" ')
if [ ! -z "$REPO_NAMES" ]; then
    echo "ECR repository $IMAGE_REPO_NAME already exists"
else
    echo "Creating ECR repository $IMAGE_REPO_NAME"
    aws ecr create-repository --repository-name $IMAGE_REPO_NAME
    aws ecr set-repository-policy --repository-name $IMAGE_REPO_NAME --policy-text file://$(pwd)/ecr-policy.json
fi


docker build -t $IMAGE_REPO_NAME:$IMAGE_TAG .
docker tag $IMAGE_REPO_NAME:$IMAGE_TAG $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG


LST_FCN=$(aws lambda list-functions | grep "FunctionName" | grep "$IMAGE_REPO_NAME" | cut -d ':' -f2 |  tr -d '" ,')
if [ "$LST_FCN" = "$IMAGE_REPO_NAME" ]; then
    aws lambda update-function-code --function-name $IMAGE_REPO_NAME --image-uri $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG
fi
