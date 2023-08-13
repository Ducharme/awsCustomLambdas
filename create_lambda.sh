#!/bin/sh

IMAGE_REPO_NAME=my-hello-lambda
IMAGE_TAG=latest

IAM_ROLE_NAME=$IMAGE_REPO_NAME-role
IAM_SERVICE_PATH=/service-role/

AWS_DEFAULT_REGION=$(aws configure get region)
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)


aws lambda create-function \
    --function-name $IMAGE_REPO_NAME \
    --package-type Image \
    --code ImageUri=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG \
    --role arn:aws:iam::$AWS_ACCOUNT_ID:role$IAM_SERVICE_PATH$IAM_ROLE_NAME
