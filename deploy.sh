#!/bin/sh

REGION="us-east-1"
SERVICE_NAME="springbootapp"
SERVICE_TAG="v1.0.6"
AWS_ACCOUNT_ID="058264261029"
ECR_REPO_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${SERVICE_NAME}"

if [ "$1" = "build" ];then
    cd ..
    sh mvn clean install
elif [ "$1" = "test" ];then
    echo $SERVICE_NAME
    find ./target/ -type f \( -name "*.jar" -not -name "*sources.jar" \) -exec cp {} ./$SERVICE_NAME.jar \;
elif [ "$1" = "dockerize" ];then
    find ../target/ -type f \( -name "*.jar" -not -name "*sources.jar" \) -exec cp {} ../deploy/$SERVICE_NAME.jar \;
#     # 检查仓库是否存在
#    if ! aws ecr describe-repositories --repository-names ${SERVICE_NAME} --region ${REGION} 2>/dev/null; then
#            aws ecr create-repository --repository-name ${SERVICE_NAME} --region ${REGION}
#    fi
#    aws ecr get-login-password \
#    --region ${REGION} \
#    | docker login \
#    --username AWS \
#    --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com
#
#    docker build --platform linux/amd64 -t ${SERVICE_NAME}:${SERVICE_TAG} .
    docker build -t ${SERVICE_NAME}:${SERVICE_TAG} .
    docker tag ${SERVICE_NAME}:${SERVICE_TAG} ${ECR_REPO_URL}:${SERVICE_TAG}
#    docker push ${ECR_REPO_URL}:${SERVICE_TAG}
elif [ "$1" = "plan" ];then
    cd infrastructure
    terraform init -backend-config="app-prod.config"
    terraform plan -var-file="production.tfvars" -var "docker_image_url=$ECR_REPO_URL:$SERVICE_TAG"
elif [ "$1" = "deploy" ];then
    cd infrastructure
    terraform init -backend-config="app-prod.config"
    terraform apply -var-file="production.tfvars" -var "docker_image_url=$ECR_REPO_URL:$SERVICE_TAG" -auto-approve
elif [ "$1" = "destroy" ];then
    cd infrastructure
    terraform init -backend-config="app-prod.config"
    terraform destroy -var-file="production.tfvars" -var "docker_image_url=$ECR_REPO_URL:$SERVICE_TAG" -auto-approve
fi
