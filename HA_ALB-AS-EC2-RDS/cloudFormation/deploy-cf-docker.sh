#!/bin/bash

# Script deployment nested stacks con Docker desde S3
# Uso: ./deploy-docker.sh [stack-name] [key-pair] [db-password] [bucket-name]

# Comentar set -e para que no se cierre en errores
# set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

STACK_NAME=${1:-"aws-ha-webapp"}
KEY_PAIR_NAME=${2:-""}
DB_PASSWORD=${3:-""}
BUCKET_NAME=${4:-"${STACK_NAME}-docker-$(date +%s)"}
REGION=${AWS_DEFAULT_REGION:-"us-east-1"}
TEMPLATES_BUCKET="${STACK_NAME}-templates-$(date +%s)"

echo -e "${GREEN}=== Deployment Nested Stacks con Docker ===${NC}"

if [ -z "$KEY_PAIR_NAME" ] || [ -z "$DB_PASSWORD" ]; then
    echo -e "${RED}Error: Key pair y password son requeridos${NC}"
    echo "Uso: $0 [stack-name] [key-pair] [db-password] [bucket-name]"
    echo -e "${YELLOW}Para crear key pair: aws ec2 create-key-pair --key-name mi-keypair --query 'KeyMaterial' --output text > mi-keypair.pem${NC}"
    exit 1
fi

# Validar que el key pair existe
if ! aws ec2 describe-key-pairs --key-names "$KEY_PAIR_NAME" > /dev/null 2>&1; then
    echo -e "${RED}Error: Key Pair '$KEY_PAIR_NAME' no existe${NC}"
    echo -e "${YELLOW}Crear con: aws ec2 create-key-pair --key-name $KEY_PAIR_NAME --query 'KeyMaterial' --output text > $KEY_PAIR_NAME.pem${NC}"
    exit 1
fi

echo -e "${YELLOW}Paso 1: Construyendo imagen Docker...${NC}"
cd ../application
docker build -t $STACK_NAME .
docker save $STACK_NAME:latest | gzip > ${STACK_NAME}.tar.gz

echo -e "${YELLOW}Paso 2: Creando buckets S3...${NC}"
aws s3 mb s3://$BUCKET_NAME --region $REGION 2>/dev/null || true
aws s3 mb s3://$TEMPLATES_BUCKET --region $REGION 2>/dev/null || true

echo -e "${YELLOW}Paso 3: Subiendo imagen Docker a S3...${NC}"
aws s3 cp ${STACK_NAME}.tar.gz s3://$BUCKET_NAME/

echo -e "${YELLOW}Paso 4: Subiendo templates nested a S3...${NC}"
cd ../CloudFormation
aws s3 cp vpc.yaml s3://$TEMPLATES_BUCKET/vpc.yaml
aws s3 cp compute-docker.yaml s3://$TEMPLATES_BUCKET/compute-docker.yaml
aws s3 cp database.yaml s3://$TEMPLATES_BUCKET/database.yaml

echo -e "${YELLOW}Paso 5: Desplegando stack master...${NC}"
aws cloudformation create-stack \
    --stack-name $STACK_NAME \
    --template-body file://master-docker.yaml \
    --parameters \
        ParameterKey=ProjectName,ParameterValue=$STACK_NAME \
        ParameterKey=KeyPairName,ParameterValue=$KEY_PAIR_NAME \
        ParameterKey=DBPassword,ParameterValue=$DB_PASSWORD \
        ParameterKey=S3Bucket,ParameterValue=$BUCKET_NAME \
        ParameterKey=DockerImageName,ParameterValue=${STACK_NAME}.tar.gz \
        ParameterKey=TemplatesBucket,ParameterValue=$TEMPLATES_BUCKET \
    --capabilities CAPABILITY_NAMED_IAM

echo -e "${YELLOW}Esperando deployment...${NC}"
aws cloudformation wait stack-create-complete --stack-name $STACK_NAME

echo -e "${GREEN}=== Deployment Completado ===${NC}"
APP_URL=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --query 'Stacks[0].Outputs[?OutputKey==`ApplicationURL`].OutputValue' --output text)
echo -e "${GREEN}Application URL: $APP_URL${NC}"

# Limpiar archivo temporal
cd ../application
rm ${STACK_NAME}.tar.gz

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

echo -e "${YELLOW}Docker Bucket: $BUCKET_NAME${NC}"
echo -e "${YELLOW}Templates Bucket: $TEMPLATES_BUCKET${NC}"

# Mantener ventana abierta para ver resultados
echo -e "${GREEN}Presiona cualquier tecla para cerrar...${NC}"
read -n 1 -s