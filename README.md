
# Prerequisites

AWS CLI v2 configured
Docker installed
jq installed
git configured


# Setup

git clone https://github.com/Ducharme/helloWorldDockerizedlambda.git

sh build_image.sh
sh create_role.sh
sh create_lambda.sh
sh run_container_locally.sh
sh run_container_remotely.sh
sh create_api.sh
