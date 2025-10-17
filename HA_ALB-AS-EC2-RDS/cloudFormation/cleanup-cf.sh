#!/bin/bash

# Script para limpiar recursos de AWS
# Uso: ./cleanup.sh [stack-name]

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

STACK_NAME=${1:-"aws-ha-webapp"}

echo -e "${YELLOW}=== Limpieza de recursos AWS ===${NC}"
echo "Stack Name: $STACK_NAME"

# Confirmar eliminacion
read -p "¿Estas seguro de que deseas eliminar el stack '$STACK_NAME'? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operacion cancelada."
    exit 0
fi

# Obtener buckets S3 del stack antes de eliminarlo
echo -e "${YELLOW}Obteniendo buckets S3 del stack...${NC}"
DOCKER_BUCKET=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --query 'Stacks[0].Parameters[?ParameterKey==`S3Bucket`].ParameterValue' --output text 2>/dev/null || echo "")
TEMPLATES_BUCKET=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --query 'Stacks[0].Parameters[?ParameterKey==`TemplatesBucket`].ParameterValue' --output text 2>/dev/null || echo "")

# Eliminar objetos y buckets S3
if [ ! -z "$DOCKER_BUCKET" ]; then
    echo -e "${YELLOW}Vaciando bucket Docker: $DOCKER_BUCKET${NC}"
    aws s3 rm s3://$DOCKER_BUCKET --recursive 2>/dev/null || true
    aws s3 rb s3://$DOCKER_BUCKET 2>/dev/null || true
fi

if [ ! -z "$TEMPLATES_BUCKET" ]; then
    echo -e "${YELLOW}Vaciando bucket Templates: $TEMPLATES_BUCKET${NC}"
    aws s3 rm s3://$TEMPLATES_BUCKET --recursive 2>/dev/null || true
    aws s3 rb s3://$TEMPLATES_BUCKET 2>/dev/null || true
fi

echo -e "${YELLOW}Eliminando stack de CloudFormation...${NC}"
aws cloudformation delete-stack --stack-name $STACK_NAME

echo -e "${YELLOW}Esperando que el stack se elimine completamente...${NC}"
aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME

echo -e "${GREEN}Stack y buckets S3 eliminados exitosamente.${NC}"
echo -e "${YELLOW}Verifica en la consola de AWS que todos los recursos fueron eliminados.${NC}"