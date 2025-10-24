#!/bin/bash

# Script para build y push de imagen Docker a ECR
# Uso: ./ecr-push.sh [project-name] [region]

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PROJECT_NAME=${1:-"aws-ha-webapp"}
REGION=${2:-${AWS_DEFAULT_REGION:-"us-east-1"}}

echo -e "${GREEN}=== Build y Push Docker a ECR ===${NC}"

# Get AWS Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: No se pudo obtener AWS Account ID${NC}"
    exit 1
fi

ECR_REPO_NAME="${PROJECT_NAME}-repo"
ECR_URI="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPO_NAME}"

echo -e "${YELLOW}Paso 1: Verificando repositorio ECR...${NC}"
aws ecr describe-repositories --repository-names $ECR_REPO_NAME --region $REGION > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}Repositorio no existe. Creando...${NC}"
    aws ecr create-repository --repository-name $ECR_REPO_NAME --region $REGION
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: No se pudo crear repositorio ECR${NC}"
        exit 1
    fi
fi

echo -e "${YELLOW}Paso 2: Autenticando Docker con ECR...${NC}"
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_URI
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Fallo la autenticación con ECR${NC}"
    exit 1
fi

echo -e "${YELLOW}Paso 3: Construyendo imagen Docker...${NC}"
cd ../application
docker build -t $ECR_REPO_NAME:latest .
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Fallo al construir imagen Docker${NC}"
    exit 1
fi

echo -e "${YELLOW}Paso 4: Taggeando imagen...${NC}"
docker tag $ECR_REPO_NAME:latest $ECR_URI:latest
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Fallo al taggear imagen${NC}"
    exit 1
fi

echo -e "${YELLOW}Paso 5: Subiendo imagen a ECR...${NC}"
docker push $ECR_URI:latest
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Fallo al subir imagen a ECR${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Imagen Docker subida exitosamente a ECR${NC}"
echo -e "${YELLOW}ECR Repository: ${ECR_URI}${NC}"
echo ""
echo -e "${GREEN}Ahora puedes ejecutar:${NC}"
echo "terraform apply"
