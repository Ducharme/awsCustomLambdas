#!/bin/sh

. ./set_common_env-vars.sh


LAMBDA_ARN=arn:aws:lambda:$AWS_DEFAULT_REGION:$AWS_ACCOUNT_ID:function:$LAMBDA_FCN_NAME
PUT_LOG_POLICY=$PROJECT_NAME-api-policy

# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/logs/create-log-group.html

echo "aws logs create-log-group --log-group-name $API_LOG_GROUP"
aws logs create-log-group --log-group-name $API_LOG_GROUP

# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/apigatewayv2/create-api.html

echo "aws apigatewayv2 create-api --name $API_NAME --protocol-type HTTP"
aws apigatewayv2 create-api --name $API_NAME --protocol-type HTTP
API_ID=$(aws apigatewayv2 get-apis | jq ".Items [] | select (.Name == \"$API_NAME\") | .ApiId" | tr -d '" ')

echo "aws apigatewayv2 create-integration --api-id $API_ID --integration-type AWS_PROXY --integration-method $ROUTE_VERB --integration-uri $LAMBDA_ARN --payload-format-version \"1.0\""
aws apigatewayv2 create-integration --api-id $API_ID --integration-type AWS_PROXY --integration-method $ROUTE_VERB --integration-uri $LAMBDA_ARN --payload-format-version "1.0"
INT_ID=$(aws apigatewayv2 get-integrations --api-id $API_ID | jq "[.Items [] | select (.IntegrationUri == \"$LAMBDA_ARN\")][0] | .IntegrationId" | tr -d '" ')
#LAMBDA_URL=$(aws lambda get-function-url-config --function-name hello-lambda | jq '.FunctionUrl' | tr -d '" ')
#aws apigatewayv2 create-integration --api-id $API_ID --integration-type HTTP_PROXY --integration-method $ROUTE_VERB --integration-uri $LAMBDA_URL --payload-format-version "1.0"
#INT_ID=$(aws apigatewayv2 get-integrations --api-id $API_ID | jq "[.Items [] | select (.IntegrationUri == \"$LAMBDA_URL\")][0] | .IntegrationId" | tr -d '" ')


echo "aws apigatewayv2 create-route --api-id $API_ID --route-key \"$ROUTE_VERB /$ROUTE_NAME\" --target integrations/$INT_ID"
aws apigatewayv2 create-route --api-id $API_ID --route-key "$ROUTE_VERB /$ROUTE_NAME" --target integrations/$INT_ID

#https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-logging.html
echo "aws apigatewayv2 create-stage --api-id $API_ID --stage-name $STAGE_NAME --auto-deploy --access-log-settings DestinationArn=arn:aws:logs:$AWS_DEFAULT_REGION:$AWS_ACCOUNT_ID:log-group:$API_LOG_GROUP,Format='$context.identity.sourceIp - - $context.requestTime $context.httpMethod $context.routeKey $context.protocol $context.status $context.responseLength $context.requestId'"
aws apigatewayv2 create-stage --api-id $API_ID --stage-name $STAGE_NAME --auto-deploy --access-log-settings DestinationArn=arn:aws:logs:$AWS_DEFAULT_REGION:$AWS_ACCOUNT_ID:log-group:$API_LOG_GROUP,Format='$context.identity.sourceIp - - $context.requestTime $context.httpMethod $context.routeKey $context.protocol $context.status $context.responseLength $context.requestId'


echo "aws logs put-resource-policy --policy-name $PUT_LOG_POLICY --policy-document '{ "Version": "2012-10-17", "Statement": [ { "Effect": "Allow", "Principal": { "Service": [ "apigateway.amazonaws.com" ] }, "Action": [ "logs:CreateLogStream", "logs:PutLogEvents" ], "Resource": "arn:aws:logs:$AWS_DEFAULT_REGION:$AWS_ACCOUNT_ID:log-group:$API_LOG_GROUP:*" } ] }'"
aws logs put-resource-policy --policy-name $PUT_LOG_POLICY --policy-document '{ "Version": "2012-10-17", "Statement": [ { "Effect": "Allow", "Principal": { "Service": [ "apigateway.amazonaws.com" ] }, "Action": [ "logs:CreateLogStream", "logs:PutLogEvents" ], "Resource": "arn:aws:logs:$AWS_DEFAULT_REGION:$AWS_ACCOUNT_ID:log-group:$API_LOG_GROUP:*" } ] }'

RANDOM_STR=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 8 ; echo '')
aws lambda add-permission \
  --statement-id "ApiGwInvokeFunction-$API_ID" \
  --action lambda:InvokeFunction \
  --function-name $LAMBDA_ARN \
  --principal apigateway.amazonaws.com \
  --source-arn "arn:aws:execute-api:$AWS_DEFAULT_REGION:$AWS_ACCOUNT_ID:$API_ID/*/*/$LAMBDA_FCN_NAME"
  #--source-arn "arn:aws:execute-api:$AWS_DEFAULT_REGION:$AWS_ACCOUNT_ID:$API_ID/*/*/$ROUTE_NAME"
  #--source-arn "arn:aws:execute-api:$AWS_DEFAULT_REGION:$AWS_ACCOUNT_ID:$API_ID/$STAGE_NAME/$ROUTE_VERB/$ROUTE_NAME"
  # https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-lambda-authorizer.html
  # "Resource": "arn:aws:execute-api:{regionId}:{accountId}:{apiId}/{stage}/{httpVerb}/[{resource}/[{child-resources}]]"
