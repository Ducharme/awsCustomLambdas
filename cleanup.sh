#!/bin/sh

. ./set_common_env-vars.sh


# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/apigatewayv2/delete-api.html
API_ID=$(aws apigatewayv2 get-apis | jq ".Items [] | select (.Name == \"$API_NAME\") | .ApiId" | tr -d '" ')
echo "aws apigatewayv2 delete-api --api-id $API_ID"
aws apigatewayv2 delete-api --api-id $API_ID

# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/lambda/delete-function.html
echo "aws lambda delete-function --function-name $LAMBDA_FCN_NAME"
aws lambda delete-function --function-name $LAMBDA_FCN_NAME

# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ecr/delete-repository.html
echo "aws ecr delete-repository --repository-name $IMAGE_REPO_NAME --force"
aws ecr delete-repository --repository-name $IMAGE_REPO_NAME --force

# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/iam/delete-role.html
POLICY_ARNS=$(aws iam list-attached-role-policies --role-name $IAM_ROLE_NAME | jq '.AttachedPolicies[] | .PolicyArn'  | tr -d '" ')
echo "$POLICY_ARNS" | tr ' ' '\n' | while read item1; do
    POLICY_ARN="$item1"
    if [ ! -z "$POLICY_ARN" ]; then
        echo "Detaching role policy $POLICY_ARN from role $IAM_ROLE_NAME";
        aws iam detach-role-policy --role-name $IAM_ROLE_NAME --policy-arn $POLICY_ARN 1>/dev/null
    fi
done
echo "aws iam delete-role --role-name $IAM_ROLE_NAME"
aws iam delete-role --role-name $IAM_ROLE_NAME

# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/logs/delete-log-group.html
echo "aws logs delete-log-group --log-group-name $API_LOG_GROUP"
aws logs delete-log-group --log-group-name $API_LOG_GROUP
echo "aws logs delete-log-group --log-group-name $LAMBDA_LOG_GROUP"
aws logs delete-log-group --log-group-name $LAMBDA_LOG_GROUP
