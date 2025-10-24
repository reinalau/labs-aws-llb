#!/bin/bash

# Script deployment ECS Fargate con Docker desde ECR
# Uso: ./deploy-cf-docker.sh [stack-name] [db-password]

# Comentar set -e para que no se cierre en errores
# set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

STACK_NAME=${1:-"aws-ha-webapp"}
DB_PASSWORD=${2:-""}
REGION=${AWS_DEFAULT_REGION:-"us-east-1"}
TEMPLATES_BUCKET="${STACK_NAME}-templates-$(date +%s)"
ECR_REPO_NAME="${STACK_NAME}-repo"

echo -e "${GREEN}=== Deployment ECS Fargate con ECR ===${NC}"

if [ -z "$DB_PASSWORD" ]; then
    echo -e "${RED}Error: Password de base de datos es requerido${NC}"
    echo "Uso: $0 [stack-name] [db-password]"
    exit 1
fi

echo -e "${YELLOW}Paso 1: Creando repositorio ECR...${NC}"
aws ecr describe-repositories --repository-names $ECR_REPO_NAME --region $REGION > /dev/null 2>&1 || \
    aws ecr create-repository --repository-name $ECR_REPO_NAME --region $REGION

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_URI="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPO_NAME}"

echo -e "${YELLOW}Paso 2: Autenticando Docker con ECR...${NC}"
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_URI

echo -e "${YELLOW}Paso 3: Construyendo imagen Docker...${NC}"
cd ../application
docker build -t $ECR_REPO_NAME:latest .

echo -e "${YELLOW}Paso 4: Taggeando y subiendo imagen a ECR...${NC}"
docker tag $ECR_REPO_NAME:latest $ECR_URI:latest
docker push $ECR_URI:latest

echo -e "${YELLOW}Paso 5: Creando bucket S3 para templates...${NC}"
aws s3 mb s3://$TEMPLATES_BUCKET --region $REGION 2>/dev/null || true

echo -e "${YELLOW}Paso 6: Subiendo templates nested a S3...${NC}"
cd ../cloudformation
aws s3 cp vpc.yaml s3://$TEMPLATES_BUCKET/vpc.yaml
aws s3 cp fargate-docker.yaml s3://$TEMPLATES_BUCKET/fargate-docker.yaml
aws s3 cp database.yaml s3://$TEMPLATES_BUCKET/database.yaml

echo -e "${YELLOW}Paso 7: Desplegando stack master...${NC}"
aws cloudformation create-stack \
    --stack-name $STACK_NAME \
    --template-body file://master-docker.yaml \
    --parameters \
        ParameterKey=ProjectName,ParameterValue=$STACK_NAME \
        ParameterKey=DBPassword,ParameterValue=$DB_PASSWORD \
        ParameterKey=DockerImage,ParameterValue=$ECR_URI:latest \
        ParameterKey=TemplatesBucket,ParameterValue=$TEMPLATES_BUCKET \
    --capabilities CAPABILITY_NAMED_IAM

echo -e "${YELLOW}Esperando deployment...${NC}"
aws cloudformation wait stack-create-complete --stack-name $STACK_NAME

echo -e "${GREEN}=== Deployment Completado ===${NC}"
APP_URL=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --query 'Stacks[0].Outputs[?OutputKey==`ApplicationURL`].OutputValue' --output text)
echo -e "${GREEN}Application URL: $APP_URL${NC}"
echo -e "${GREEN}ECR Repository: $ECR_URI${NC}"

# Mostrar información de debugging si hay error
if [ $? -ne 0 ]; then
    echo -e "${RED}Error durante el deployment. Verificar logs:${NC}"
    echo "aws cloudformation describe-stack-events --stack-name $STACK_NAME"
    echo "aws logs describe-log-groups"
fi

# Verificar si el stack falló y mostrar eventos
STACK_STATUS=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --query 'Stacks[0].StackStatus' --output text 2>/dev/null || echo "NOT_FOUND")
if [[ "$STACK_STATUS" == "ROLLBACK_COMPLETE" || "$STACK_STATUS" == "CREATE_FAILED" ]]; then
    echo -e "${RED}Stack falló con estado: $STACK_STATUS${NC}"
    echo -e "${YELLOW}Eventos del stack (últimos 15):${NC}"
    aws cloudformation describe-stack-events --stack-name $STACK_NAME --query 'StackEvents[0:15].[Timestamp,ResourceType,LogicalResourceId,ResourceStatus,ResourceStatusReason]' --output table
    
    echo -e "${YELLOW}Eventos de error específicos:${NC}"
    aws cloudformation describe-stack-events --stack-name $STACK_NAME --query 'StackEvents[?ResourceStatus==`CREATE_FAILED`].[Timestamp,ResourceType,LogicalResourceId,ResourceStatusReason]' --output table
fi

echo -e "${YELLOW}ECR Repository: $ECR_REPO_NAME${NC}"
echo -e "${YELLOW}Templates Bucket: $TEMPLATES_BUCKET${NC}"

# Mantener ventana abierta para ver resultados
echo -e "${GREEN}Presiona cualquier tecla para cerrar...${NC}"
read -n 1 -s