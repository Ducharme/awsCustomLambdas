#!/bin/sh

. ./set_common_env-vars.sh


echo "aws lambda invoke --function-name $LAMBDA_FCN_NAME --cli-binary-format raw-in-base64-out --payload '{ "mode": "my-value" }' ./response.json"
aws lambda invoke --function-name $LAMBDA_FCN_NAME --cli-binary-format raw-in-base64-out --payload '{ "mode": "my-value" }' ./response.json

cat ./response.json
echo ""
