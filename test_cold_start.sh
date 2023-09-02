#!/bin/sh

. ./set_common_env-vars.sh

MAX=10
WAIT=30
COLD_START=TRUE


JSCODE=$(cat << EOF
exports.handler = async function(event, context) {
  try {
    console.log("Echoing event #NO: " + JSON.stringify(event));

    return {
      "isBase64Encoded": false,
      "statusCode": 200,
      "body": JSON.stringify(event)
    };
  } catch (error) {
    console.error("An hello occurred:", error);
    return {
      statusCode: 500,
      body: JSON.stringify("Internal Server Hello")
    };
  }
}
EOF
)

SHCODE=$(cat << EOF
#!/bin/bash

function handler () {
  EVENT_DATA=$1
  echo "Echoing EVENT_DATA #NO: '$EVENT_DATA'" 1>&2;

  ESCAPED=$(echo "$EVENT_DATA" | sed 's/"/\\"/g')
  RESPONSE="{ \"isBase64Encoded\": false, \"statusCode\": 200, \"body\": \"$ESCAPED\" }"
  echo $RESPONSE
}
EOF
)


START=$(date +%s%N | cut -b1-13)
#START=1692927000000
RUNFILE=./tmp/$START-RUN.log

echo "Region is $AWS_DEFAULT_REGION" >> $RUNFILE

for i in $(seq 1 1 $MAX)
do
    echo "Iteration #$i out of #$MAX"

    echo "$JSCODE" | sed "s/#NO/$i/g" > ./javascript_lambda/index.js
    echo "$SHCODE" | sed "s/#NO/$i/g" > ./shell_runtime/function.sh

    if [ ! "$DOCKERFILE" = "NA" ]; then
        echo "   Deleting images"
        REPO_NAMES=$(aws ecr describe-repositories | grep "repositoryName" | grep "$IMAGE_REPO_NAME" | cut -d ':' -f2 |  tr -d '" ')
        if [ ! -z "$REPO_NAMES" ]; then
            IMAGES=$(aws ecr describe-images --repository-name $IMAGE_REPO_NAME | jq '.imageDetails[] | .imageDigest' | tr -d ' "')
            echo "$IMAGES" | while read item1; do
                IMAGE=$item1
                if [ ! -z "$IMAGE" ]; then
                    aws ecr batch-delete-image --repository-name $IMAGE_REPO_NAME --image-ids "imageDigest=$IMAGE" >> $RUNFILE
                fi
            done
        fi
    fi

    LST_FCN=$(aws lambda list-functions | grep "FunctionName" | grep "$LAMBDA_FCN_NAME" | cut -d ':' -f2 |  tr -d '" ,')
    if [ "$LST_FCN" = "$LAMBDA_FCN_NAME" ]; then
        aws lambda delete-function --function-name $LAMBDA_FCN_NAME
    fi

    echo "   Building image"
    . ./build_image.sh >> $RUNFILE

    echo "   Creating role"
    . ./create_role.sh >> $RUNFILE

    echo "   Updating lamba"
    . ./create_lambda.sh >> $RUNFILE

    echo "   Waiting for update to complete"
    aws lambda wait function-updated-v2 --function-name $LAMBDA_FCN_NAME

    echo "   Calling lamba"
    . ./run_function_remotely.sh >> $RUNFILE

    sleep $WAIT
done


END=$(date +%s%N | cut -b1-13)
#END=1692929847000
LOGFILE=./tmp/$START-$END.log
CSVFILE=./tmp/$START-$END.csv


aws logs filter-log-events --log-group-name "/aws/lambda/$LAMBDA_FCN_NAME" --start-time $START --end-time $END --filter-pattern "Init Duration" | jq '.events[] | .message' > $LOGFILE

DATA=$(cat "$LOGFILE")
echo "Duration(ms),InitDuration(ms)" > $CSVFILE
echo "$DATA" | tr '\t' ';' | while read item1; do
    DURATION=$(echo "$item1" | cut -d ";" -f 2 | tr -d ' "\n\r')
    INIT_DUR=$(echo "$item1" | cut -d ";" -f 6 | tr -d ' "\n\r')
    DUR_VAL=$(echo "$DURATION" | sed -e "s/Duration://g")
    INI_VAL=$(echo "$INIT_DUR" | sed -e "s/InitDuration://g")
    if [ ! "$DUR_VAL $INI_VAL" = " " ]; then
        echo "$DUR_VAL,$INI_VAL" >> $CSVFILE
    fi
done
