#!/bin/sh

. ./set_common_env-vars.sh


AWS_DEFAULT_REGION=$(aws configure get region)
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
LAMBDA_ARN=arn:aws:lambda:$AWS_DEFAULT_REGION:$AWS_ACCOUNT_ID:function:$LAMBDA_FCN_NAME

# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/apigatewayv2/create-api.html

aws apigatewayv2 create-api --name $API_NAME --protocol-type HTTP
API_ID=$(aws apigatewayv2 get-apis | jq ".Items [] | select (.Name == \"$API_NAME\") | .ApiId" | tr -d '" ')

aws apigatewayv2 create-integration --api-id $API_ID --integration-type AWS_PROXY --integration-uri $LAMBDA_ARN --payload-format-version "1.0"
INT_ID=$(aws apigatewayv2 get-integrations --api-id $API_ID | jq "[.Items [] | select (.IntegrationUri == \"$LAMBDA_ARN\")][0] | .IntegrationId" | tr -d '" ')

aws apigatewayv2 create-route --api-id $API_ID --route-key "$ROUTE_VERB /$ROUTE_NAME" --target integrations/$INT_ID
aws apigatewayv2 create-stage --api-id $API_ID --stage-name $STAGE_NAME --auto-deploy

aws lambda add-permission \
  --statement-id "ApiGwInvokeFunction$RANDOM$RANDOM" \
  --action lambda:InvokeFunction \
  --function-name "$LAMBDA_ARN" \
  --principal apigateway.amazonaws.com \
  --source-arn "arn:aws:execute-api:$AWS_DEFAULT_REGION:$AWS_ACCOUNT_ID:$API_ID/*/*/$ROUTE_NAME"
