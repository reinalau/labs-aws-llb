#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PROJECT_NAME=${1:-"aws-ha-webapp"}
BUCKET_NAME=${2:-"${PROJECT_NAME}-docker-$(date +%s)"}
REGION=${AWS_DEFAULT_REGION:-"us-east-1"}

echo -e "${GREEN}=== Docker Build y Upload a S3 para Terraform ===${NC}"

echo -e "${YELLOW}Paso 1: Construyendo imagen Docker...${NC}"
cd ../application
docker build -t $PROJECT_NAME .
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Fallo al construir imagen Docker${NC}"
    exit 1
fi

echo -e "${YELLOW}Paso 2: Empaquetando imagen...${NC}"
docker save $PROJECT_NAME:latest | gzip > ${PROJECT_NAME}.tar.gz
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Fallo al empaquetar imagen${NC}"
    exit 1
fi

echo -e "${YELLOW}Paso 3: Creando bucket S3...${NC}"
aws s3 mb s3://$BUCKET_NAME --region $REGION
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Fallo al crear bucket S3${NC}"
    exit 1
fi

echo -e "${YELLOW}Paso 4: Subiendo imagen a S3...${NC}"
aws s3 cp ${PROJECT_NAME}.tar.gz s3://$BUCKET_NAME/
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Fallo al subir imagen a S3${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Imagen Docker subida exitosamente${NC}"
echo -e "${YELLOW}Bucket: s3://$BUCKET_NAME${NC}"
echo -e "${YELLOW}Archivo: ${PROJECT_NAME}.tar.gz${NC}"
echo ""
echo -e "${GREEN}Ahora puedes usar estos valores en terraform.tfvars:${NC}"
echo "s3_bucket = \"$BUCKET_NAME\""
echo "docker_image_name = \"${PROJECT_NAME}.tar.gz\""

# Limpiar archivo local
rm ${PROJECT_NAME}.tar.gz
echo -e "${GREEN}Archivo local limpiado${NC}"