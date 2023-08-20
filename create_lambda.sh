#!/bin/sh

. ./set_common_env-vars.sh

# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/lambda/create-function.html

if [ "$DOCKERFILE" = "NA" ]; then
    chmod +x ./shell_runtime/bootstrap
    chmod +x ./shell_runtime/function.sh
    zip -j function.zip ./shell_runtime/*

    echo "aws lambda create-function --function-name $LAMBDA_FCN_NAME --runtime provided.al2 --package-type Zip --handler function.handler --zip-file fileb://function.zip --role arn:aws:iam::$AWS_ACCOUNT_ID:role$IAM_SERVICE_PATH$IAM_ROLE_NAME"
    aws lambda create-function --function-name $LAMBDA_FCN_NAME --runtime provided.al2 --package-type Zip --handler function.handler --zip-file fileb://function.zip --role arn:aws:iam::$AWS_ACCOUNT_ID:role$IAM_SERVICE_PATH$IAM_ROLE_NAME
else
    echo "aws lambda create-function --function-name $LAMBDA_FCN_NAME --package-type Image --code ImageUri=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG --role arn:aws:iam::$AWS_ACCOUNT_ID:role$IAM_SERVICE_PATH$IAM_ROLE_NAME"
    aws lambda create-function --function-name $LAMBDA_FCN_NAME --package-type Image --code ImageUri=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG --role arn:aws:iam::$AWS_ACCOUNT_ID:role$IAM_SERVICE_PATH$IAM_ROLE_NAME

    #aws lambda create-function-url-config --function-name $LAMBDA_FCN_NAME --auth-type NONE

    # NOTE1: Restricting to "--principal apigateway.amazonaws.com" does not work
    # NOTE2: Condition options is not supported by AWS CLI.
    #   Using AWS console Lambda / Configuration / Function URL / Edit button 
    #   is the only way to grant required access when auth type is NONE.
    
    # aws lambda add-permission \
    #     --statement-id "FunctionURLAllowPublicAccess" \
    #     --action lambda:InvokeFunctionUrl \
    #     --function-name $LAMBDA_FCN_NAME \
    #     --principal "*" \
    #     --source-arn $LAMBDA_ARN \
    #     --condition '{"StringEquals": {"lambda:FunctionUrlAuthType": "NONE"}}'

fi
