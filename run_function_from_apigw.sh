#!/bin/sh

. ./set_common_env-vars.sh


API_EP=$(aws apigatewayv2 get-apis | jq ".Items [] | select (.Name == \"$API_NAME\") | .ApiEndpoint" | tr -d '" ')

echo "curl -X $ROUTE_VERB $API_EP/$STAGE_NAME/$ROUTE_NAME -d '{"mode": "my-value-2"}'"
curl -X $ROUTE_VERB $API_EP/$STAGE_NAME/$ROUTE_NAME -d '{"mode": "my-value-2"}'
#FOR DEBUGGING -> curl -s --raw --show-error --verbose -L -X $ROUTE_VERB $API_EP/$STAGE_NAME/$ROUTE_NAME -d '{"mode": "my-value-2"}'
echo ""
