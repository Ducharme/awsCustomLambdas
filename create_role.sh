#!/bin/sh

. ./set_common_env-vars.sh

# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/iam/create-role.html

aws iam create-role --role-name $IAM_ROLE_NAME --path $IAM_SERVICE_PATH --assume-role-policy-document file://./lambda-trust-policy.json
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole --role-name $IAM_ROLE_NAME
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaRole --role-name $IAM_ROLE_NAME
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly --role-name $IAM_ROLE_NAME
