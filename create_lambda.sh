#!/bin/sh

. ./set_common_env-vars.sh

# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/lambda/create-function.html

if [ "$DOCKERFILE" = "NA" ]; then

    ZIP_DIR=tmp
    ZIP_FILE=./$ZIP_DIR/function.zip
    mkdir -p $ZIP_DIR

    if test -f "$FILE"; then
        rm ./tmp/function.zip
    fi

    if [ "$RUNTIME_ID" = "provided.al2" ]; then
        FUNCTION_HANDLER=function.handler
        chmod +x ./shell_runtime/bootstrap
        chmod +x ./shell_runtime/function.sh
        zip -j $ZIP_FILE ./shell_runtime/*
    else
        FUNCTION_HANDLER=index.handler
        zip -j $ZIP_FILE ./javascript_lambda/*
    fi

    # In case the function  already exists, update the zip file for the function otherwise old code will still execute
    LST_FCN=$(aws lambda list-functions | grep "FunctionName" | grep "$LAMBDA_FCN_NAME" | cut -d ':' -f2 |  tr -d '" ,')
    if [ "$LST_FCN" = "$LAMBDA_FCN_NAME" ]; then
        echo "aws lambda update-function-code --function-name $LAMBDA_FCN_NAME --zip-file fileb://$ZIP_FILE"
        aws lambda update-function-code --function-name $LAMBDA_FCN_NAME --zip-file fileb://$ZIP_FILE
    else
        echo "aws lambda create-function --function-name $LAMBDA_FCN_NAME --runtime $RUNTIME_ID --package-type Zip --handler $FUNCTION_HANDLER --zip-file fileb://$ZIP_FILE --role arn:aws:iam::$AWS_ACCOUNT_ID:role$IAM_SERVICE_PATH$IAM_ROLE_NAME --memory-size $LAMBDA_MEM_SIZE"
        aws lambda create-function --function-name $LAMBDA_FCN_NAME --runtime $RUNTIME_ID --package-type Zip --handler $FUNCTION_HANDLER --zip-file fileb://$ZIP_FILE --role arn:aws:iam::$AWS_ACCOUNT_ID:role$IAM_SERVICE_PATH$IAM_ROLE_NAME --memory-size $LAMBDA_MEM_SIZE
    fi
else
    # In case the function  already exists, update the docker image for the function otherwise old code will still execute
    LST_FCN=$(aws lambda list-functions | grep "FunctionName" | grep "$LAMBDA_FCN_NAME" | cut -d ':' -f2 |  tr -d '" ,')
    if [ "$LST_FCN" = "$LAMBDA_FCN_NAME" ]; then
        echo "aws lambda update-function-code --function-name $LAMBDA_FCN_NAME --image-uri $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG"
        aws lambda update-function-code --function-name $LAMBDA_FCN_NAME --image-uri $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG
    else
        echo "aws lambda create-function --function-name $LAMBDA_FCN_NAME --package-type Image --code ImageUri=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG --role arn:aws:iam::$AWS_ACCOUNT_ID:role$IAM_SERVICE_PATH$IAM_ROLE_NAME --memory-size $LAMBDA_MEM_SIZE"
        aws lambda create-function --function-name $LAMBDA_FCN_NAME --package-type Image --code ImageUri=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG --role arn:aws:iam::$AWS_ACCOUNT_ID:role$IAM_SERVICE_PATH$IAM_ROLE_NAME --memory-size $LAMBDA_MEM_SIZE
    fi


    #aws lambda create-function-url-config --function-name $LAMBDA_FCN_NAME --auth-type NONE

    # NOTE1: Restricting to "--principal apigateway.amazonaws.com" does not work
    # NOTE2: Condition option is not supported by AWS CLI.
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
