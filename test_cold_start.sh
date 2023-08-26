#!/bin/sh

. ./set_common_env-vars.sh

MAX=100
WAIT=60

START=$(date +%s%N | cut -b1-13)
#START=1692927000000
RUNFILE=./tmp/$START-RUN.log

for i in $(seq 1 1 $MAX)
do
   echo "Iteration #$i out of #$MAX"

   echo "   Updating lamba"
   . ./create_lambda.sh >> $RUNFILE

    echo "   Waiting for update to complete"
    aws lambda wait function-updated-v2 --function-name $LAMBDA_FCN_NAME

    echo "   Calling lamba"
    . ./run_function_remotely.sh >> $RUNFILE

    sleep $WAIT
done

sleep $WAIT

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
