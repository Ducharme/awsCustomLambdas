#!/bin/sh

IMAGE_REPO_NAME=my-hello-lambda
IAM_SERVICE_PATH=/service-role/
IAM_POLICY_NAME=$IMAGE_REPO_NAME-policy
IAM_ROLE_NAME=$IMAGE_REPO_NAME-role
IAM_TRUST_POLICY=./lambda-trust-policy.json

aws iam create-role --role-name $IAM_ROLE_NAME --path $IAM_SERVICE_PATH --assume-role-policy-document file://$IAM_TRUST_POLICY
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole --role-name $IAM_ROLE_NAME
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaRole --role-name $IAM_ROLE_NAME
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly --role-name $IAM_ROLE_NAME
