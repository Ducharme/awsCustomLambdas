#!/bin/sh

. ./set_common_env-vars.sh

# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/lambda/create-function.html

if [ "$DOCKERFILE" = "NA" ]; then
    chmod +x ./shell_runtime/bootstrap
    chmod +x ./shell_runtime/function.sh
    zip -j function.zip ./shell_runtime/*

    aws lambda create-function \
        --function-name $LAMBDA_FCN_NAME \
        --runtime provided.al2 \
        --package-type Zip \
        --handler function.handler \
        --zip-file fileb://function.zip \
        --role arn:aws:iam::$AWS_ACCOUNT_ID:role$IAM_SERVICE_PATH$IAM_ROLE_NAME
else
    aws lambda create-function \
        --function-name $LAMBDA_FCN_NAME \
        --package-type Image \
        --code ImageUri=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG \
        --role arn:aws:iam::$AWS_ACCOUNT_ID:role$IAM_SERVICE_PATH$IAM_ROLE_NAME
fi
