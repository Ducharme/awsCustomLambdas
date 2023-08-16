#!/bin/bash

echo "Loading function from Amazon Linux 2"

function handler () {
  echo "Executing handler function from Amazon Linux 2"
  EVENT_DATA=$1
  echo "$EVENT_DATA" 1>&2;
  
  RESPONSE="Echoing request: '$EVENT_DATA'"
  echo $RESPONSE
}
