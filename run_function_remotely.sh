#!/bin/sh

. ./set_common_env-vars.sh

RESPONSE_DIR=tmp
RESPONSE_FILE=./$RESPONSE_DIR/response.json

mkdir -p $RESPONSE_DIR

echo "aws lambda invoke --function-name $LAMBDA_FCN_NAME --cli-binary-format raw-in-base64-out --payload '{ "mode": "my-value" }' $RESPONSE_FILE"
aws lambda invoke --function-name $LAMBDA_FCN_NAME --cli-binary-format raw-in-base64-out --payload '{ "mode": "my-value" }' "$RESPONSE_FILE"

cat "$RESPONSE_FILE"
echo ""
