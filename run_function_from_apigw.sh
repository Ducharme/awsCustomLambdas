#!/bin/sh

. ./set_common_env-vars.sh


API_EP=$(aws apigatewayv2 get-apis | jq ".Items [] | select (.Name == \"$API_NAME\") | .ApiEndpoint" | tr -d '" ')

sleep 5
curl -X $ROUTE_VERB $API_EP/$ROUTE_NAME -d '{"mode": "my-value-1"}'
echo ""
curl -X $ROUTE_VERB $API_EP/$STAGE_NAME/$ROUTE_NAME -d '{"mode": "my-value-2"}'
echo ""
