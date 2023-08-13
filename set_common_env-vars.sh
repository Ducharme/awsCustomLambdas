#!/bin/sh

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_DEFAULT_REGION=$(aws configure get region)

API_NAME=hello-api
LAMBDA_FCN_NAME=hello-lambda
IMAGE_REPO_NAME=hello-repo
IMAGE_TAG=latest

IAM_SERVICE_PATH=/service-role/
IAM_ROLE_NAME=$LAMBDA_FCN_NAME-role
