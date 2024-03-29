
# Related information

[How to configure custom docker images for AWS lambda functions (ubuntu with bash/shell & nodejs - Medium article written by me](https://medium.com/@claude.ducharme/how-to-configure-custom-docker-images-for-aws-lambda-functions-ubuntu-with-bash-shell-nodejs-e1d6592c88b3)


# Prerequisites

1. AWS CLI v2 configured
2. Docker installed
3. git configured
4. jq installed
5. zip installed


# Setup

1. git clone https://github.com/Ducharme/awsCustomLambdas
2. Update values in file `set_project_values.sh` (defaults are PROJECT_NAME=hello and DOCKERFILE=Dockerfile_ubuntu)
  * PROJECT_NAME: Lowercase string without space plus dash '-' char are valid
  * DOCKERFILE: **Dockerfile_aws** or **Dockerfile_bookworm** or **Dockerfile_ubuntu** or **NA** (for custom image from zip file)
3. `sh build_image.sh` Note: Only for functions using docker image
4. `sh create_role.sh`
5. `sh create_lambda.sh`
6. `sh create_api.sh`


# Single test in your current region

6. `sh run_container_locally.sh` Note: Only for functions using docker image
7. `sh run_function_remotely.sh`
8. `sh run_function_from_apigw.sh`


# Global test accross multiple regions

9. `sh test_cold_start_by_region.sh`
10. `sh run_function_by_region.sh`


# Clean up

Simply run `sh cleanup.sh` to delete all resources at once
* API Gateway / APIs (**$PROJECT_NAME**-api)
* Lambda / Functions (**$PROJECT_NAME**-lambda)
* Amazon ECR / Repositories (**$PROJECT_NAME**-repo)
* IAM / Roles (**$PROJECT_NAME**-lambda-role)
* CloudWatch / Log groups (/aws/lambda/**$PROJECT_NAME**-lambda)
* CloudWatch / Log groups (/aws/apigw/**$PROJECT_NAME**-api)


# Documentation

* [Custom Lambda runtimes](https://docs.aws.amazon.com/lambda/latest/dg/runtimes-custom.html)
* [Tutorial – Publishing a custom runtime](https://docs.aws.amazon.com/lambda/latest/dg/runtimes-walkthrough.html)
* [Working with Lambda container images](https://docs.aws.amazon.com/lambda/latest/dg/images-create.html)
* [Testing Lambda container images locally](https://docs.aws.amazon.com/lambda/latest/dg/images-test.html)
* [Deploy Node.js Lambda functions with container images](https://docs.aws.amazon.com/lambda/latest/dg/nodejs-image.html)
* [Lambda runtime API](https://docs.aws.amazon.com/lambda/latest/dg/runtimes-api.html)
* [https://github.com/aws/aws-lambda-base-images/](https://github.com/aws/aws-lambda-base-images/)
* [https://gallery.ecr.aws/lambda/provided](https://gallery.ecr.aws/lambda/provided)
* [https://gallery.ecr.aws/lambda/nodejs](https://gallery.ecr.aws/lambda/nodejs)
