#!/bin/bash

# NOTE: Avoid using echo without redirect

function handler () {
  EVENT_DATA=$1
  echo "$EVENT_DATA" 1>&2;

  # Should be valid json
  #echo "{ \"isBase64Encoded\": false, \"statusCode\": \"200\", \"body\": \"{\"status\": \"OK\", \"statusCode\": \"200\"}\" }"
  RESPONSE="Echoing request: '$EVENT_DATA'"
  echo $RESPONSE
}
