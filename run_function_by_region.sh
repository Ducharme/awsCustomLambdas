#!/bin/sh

SHORT_WAIT=5
LONG_WAIT=15
REGIONS=$(cat "./aws-regions.csv")
echo "$REGIONS" | while read item1; do
    REGION_NAME=$(echo "$item1" | cut -d "," -f 1 | tr -d '\n\r')
    REGION_CODE=$(echo "$item1" | cut -d "," -f 2 | tr -d '\n\r')

    if [ "$REGION_NAME" = "Name" ] || [ -z "$REGION_NAME" ]; then
        continue
    else
        START=$(date +%s%N | cut -b1-13)
        RUNFILE=./tmp/$START-RUN.log

        echo "Setting region to $REGION_CODE for $REGION_NAME"
        echo "Setting region to $REGION_CODE for $REGION_NAME" >> $RUNFILE
        aws configure set region $REGION_CODE >> $RUNFILE

        . ./set_common_env-vars.sh  >> $RUNFILE
        aws lambda update-function-configuration --function-name $LAMBDA_FCN_NAME --memory-size $LAMBDA_MEM_SIZE >> $RUNFILE

        sleep $SHORT_WAIT
        echo "   Calling lamba"
        . ./run_function_remotely.sh >> $RUNFILE
        sleep $LONG_WAIT

        END=$(date +%s%N | cut -b1-13)
        LOGFILE=./tmp/$START-$END.log
        CSVFILE=./tmp/$START-$END.csv

        aws logs filter-log-events --log-group-name "/aws/lambda/$LAMBDA_FCN_NAME" --start-time $START --end-time $END --filter-pattern "Duration" | jq '.events[] | .message' > $LOGFILE

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
    fi
done
