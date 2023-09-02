#!/bin/sh

. ./set_common_env-vars.sh

IAM_ROLE_BY_NAME=$(aws iam get-role --role-name $IAM_ROLE_NAME | grep "RoleName" | grep "$IAM_ROLE_NAME" | cut -d ':' -f2 |  tr -d '" ,')
if [ -z "$IAM_ROLE_BY_NAME" ]; then
    # https://awscli.amazonaws.com/v2/documentation/api/latest/reference/iam/create-role.html

    echo "aws iam create-role --role-name $IAM_ROLE_NAME --path $IAM_SERVICE_PATH --assume-role-policy-document file://./lambda-trust-policy.json"
    aws iam create-role --role-name $IAM_ROLE_NAME --path $IAM_SERVICE_PATH --assume-role-policy-document file://./lambda-trust-policy.json

    echo "aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole --role-name $IAM_ROLE_NAME"
    aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole --role-name $IAM_ROLE_NAME

    echo "aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaRole --role-name $IAM_ROLE_NAME"
    aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaRole --role-name $IAM_ROLE_NAME

    echo "aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly --role-name $IAM_ROLE_NAME"
    aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly --role-name $IAM_ROLE_NAME
else
    echo "Role $IAM_ROLE_NAME already exists"
fi
