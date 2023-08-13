#!/bin/sh

. ./set_common_env-vars.sh


aws lambda create-function \
    --function-name $LAMBDA_FCN_NAME \
    --package-type Image \
    --code ImageUri=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG \
    --role arn:aws:iam::$AWS_ACCOUNT_ID:role$IAM_SERVICE_PATH$IAM_ROLE_NAME
