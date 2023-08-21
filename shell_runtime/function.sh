#!/bin/bash

# NOTE: Avoid using echo without redirect

function handler () {
  EVENT_DATA=$1
  echo "Echoing EVENT_DATA: '$EVENT_DATA'" 1>&2;

  # NOTE: Must be valid json. Not escaping body payload as json will return 200 in lambda but 500 in api gateway
  # OK -> RESPONSE='{ "isBase64Encoded": false, "statusCode": 200, "body": "{ \"allo\": \"hehe\" }" }'
  # Console test execution log -> { "isBase64Encoded": false, "statusCode": 200, "body": "{\"allo\": \"hehe\"}" }

  ESCAPED=$(echo "$EVENT_DATA" | sed 's/"/\\"/g')
  RESPONSE="{ \"isBase64Encoded\": false, \"statusCode\": 200, \"body\": \"$ESCAPED\" }"
  echo $RESPONSE
}
