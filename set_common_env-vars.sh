#!/bin/sh

. ./set_project_values.sh

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_DEFAULT_REGION=$(aws configure get region)

# Lambda variable
LAMBDA_FCN_NAME=$PROJECT_NAME-lambda

# ECR & docker image variables
IMAGE_REPO_NAME=$PROJECT_NAME-repo
IMAGE_TAG=latest

# API Gateway variables
API_NAME=$PROJECT_NAME-api
STAGE_NAME=dev
ROUTE_VERB=POST
ROUTE_NAME=resource

# IAM variables
IAM_SERVICE_PATH=/service-role/
IAM_ROLE_NAME=$LAMBDA_FCN_NAME-role
