#!/bin/bash

# Script para limpiar recursos de AWS (ECS Fargate + ECR)
# Uso: ./cleanup-cf.sh [stack-name]

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

STACK_NAME=${1:-"aws-ha-webapp"}
REGION=${AWS_DEFAULT_REGION:-"us-east-1"}
ECR_REPO_NAME="${STACK_NAME}-repo"

echo -e "${YELLOW}=== Limpieza de recursos AWS ===${NC}"
echo "Stack Name: $STACK_NAME"
echo "Region: $REGION"

# Confirmar eliminacion
read -p "¿Estas seguro de que deseas eliminar el stack '$STACK_NAME' y todos sus recursos? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operacion cancelada."
    exit 0
fi

# Obtener bucket de templates del stack
echo -e "${YELLOW}Paso 1: Obteniendo bucket S3 de templates...${NC}"
TEMPLATES_BUCKET=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --query 'Stacks[0].Parameters[?ParameterKey==`TemplatesBucket`].ParameterValue' --output text 2>/dev/null || echo "")

# Eliminar bucket de templates
if [ ! -z "$TEMPLATES_BUCKET" ]; then
    echo -e "${YELLOW}Vaciando bucket Templates: $TEMPLATES_BUCKET${NC}"
    aws s3 rm s3://$TEMPLATES_BUCKET --recursive 2>/dev/null || true
    aws s3 rb s3://$TEMPLATES_BUCKET 2>/dev/null || true
fi

echo -e "${YELLOW}Paso 2: Eliminando stack de CloudFormation...${NC}"
aws cloudformation delete-stack --stack-name $STACK_NAME

echo -e "${YELLOW}Esperando que el stack se elimine completamente...${NC}"
aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME

echo -e "${YELLOW}Paso 3: Eliminando imágenes de ECR...${NC}"
if aws ecr describe-repositories --repository-names $ECR_REPO_NAME --region $REGION > /dev/null 2>&1; then
    echo -e "${YELLOW}Eliminando todas las imágenes del repositorio ECR: $ECR_REPO_NAME${NC}"
    IMAGE_IDS=$(aws ecr list-images --repository-name $ECR_REPO_NAME --region $REGION --query 'imageIds[*]' --output json)
    
    if [ "$IMAGE_IDS" != "[]" ]; then
        aws ecr batch-delete-image --repository-name $ECR_REPO_NAME --region $REGION --image-ids "$IMAGE_IDS" 2>/dev/null || true
    fi
    
    echo -e "${YELLOW}Eliminando repositorio ECR: $ECR_REPO_NAME${NC}"
    aws ecr delete-repository --repository-name $ECR_REPO_NAME --region $REGION --force 2>/dev/null || true
else
    echo -e "${YELLOW}Repositorio ECR no encontrado, omitiendo...${NC}"
fi

echo -e "${GREEN}=== Limpieza Completada ===${NC}"
echo -e "${GREEN}✓ Stack CloudFormation eliminado${NC}"
echo -e "${GREEN}✓ Bucket S3 de templates eliminado${NC}"
echo -e "${GREEN}✓ Repositorio ECR eliminado${NC}"
echo -e "${YELLOW}Verifica en la consola de AWS que todos los recursos fueron eliminados correctamente.${NC}"