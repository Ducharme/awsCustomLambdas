#!/bin/sh


REGIONS=$(cat "./aws-regions.csv")
echo "$REGIONS" | while read item1; do
    REGION_NAME=$(echo "$item1" | cut -d "," -f 1 | tr -d '\n\r')
    REGION_CODE=$(echo "$item1" | cut -d "," -f 2 | tr -d '\n\r')

    if [ "$REGION_NAME" = "Name" ] || [ -z "$REGION_NAME" ]; then
        continue
    else
        echo "Setting region to $REGION_CODE for $REGION_NAME"
        aws configure set region $REGION_CODE
        . ./test_cold_start.sh
    fi
done
