#!/bin/bash
# ============================================================
# delete-cloudformation.sh — Elimina el stack de Mariposas
# ============================================================
# Este script:
#   1. Vacía los buckets S3 (CloudFormation no puede eliminar
#      buckets con objetos, falla si no se vacían primero)
#   2. Elimina el stack CloudFormation completo
#
# Prerrequisitos:
#   - AWS CLI configurado (aws configure)
#   - El stack debe existir en la región especificada
#
# Uso:
#   ./delete-cloudformation.sh
# ============================================================

set -e # Terminar en caso de error principal

REGION="us-east-1"
STACK_NAME="mariposas-webapp"

echo ""
echo -e "\e[31m==========================================\e[0m"
echo -e "\e[31m Mariposas — Eliminando stack             \e[0m"
echo -e "\e[31m==========================================\e[0m"
echo -e "\e[33m Stack  : $STACK_NAME\e[0m"
echo -e "\e[33m Region : $REGION\e[0m"
echo ""
echo -e "\e[33m⚠️  Se eliminarán TODOS los recursos del stack.\e[0m"
echo ""

# ── [1/3] Obtener nombres de los buckets S3 ──────────────
echo -e "\e[36m[1/3] Obteniendo nombres de buckets S3 del stack...\e[0m"

set +e # Desactivar exit on error
FRONTEND_BUCKET=$(aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --region "$REGION" \
    --query "Stacks[0].Outputs[?OutputKey=='FrontendBucketName'].OutputValue" \
    --output text 2>/dev/null)

IMAGES_BUCKET=$(aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --region "$REGION" \
    --query "Stacks[0].Outputs[?OutputKey=='ImagesBucketName'].OutputValue" \
    --output text 2>/dev/null)
set -e

if [ -z "$FRONTEND_BUCKET" ] && [ -z "$IMAGES_BUCKET" ]; then
    echo -e "\e[33mWARN: No se pudo describir el stack o estaba vacío. Puede que no exista.\e[0m"
    echo -e "\e[33mIntentando eliminar de todas formas...\e[0m"
else
    # ── [2/3] Vaciar los buckets S3 antes de eliminar el stack ──
    echo -e "\e[36m[2/3] Vaciando buckets S3 (necesario antes de eliminar el stack)...\e[0m"

    for BUCKET in "$FRONTEND_BUCKET" "$IMAGES_BUCKET"; do
        if [ -n "$BUCKET" ] && [ "$BUCKET" != "None" ]; then
            echo -e "\e[33m  Vaciando bucket: $BUCKET\e[0m"
            set +e
            aws s3 rm "s3://$BUCKET" --recursive --region "$REGION" > /dev/null
            if [ $? -ne 0 ]; then
                echo -e "\e[33m  WARN: No se pudo vaciar $BUCKET (puede estar vacío)\e[0m"
            else
                echo -e "\e[32m  Bucket vaciado.\e[0m"
            fi
            set -e
        fi
    done
fi

# ── [3/4] Eliminar el stack CloudFormation ────────────────
echo ""
echo -e "\e[36m[3/4] Eliminando stack CloudFormation (esto puede tardar varios minutos)...\e[0m"

set +e
aws cloudformation delete-stack \
    --stack-name "$STACK_NAME" \
    --region "$REGION"
if [ $? -ne 0 ]; then
    echo -e "\e[31mERROR: No se pudo iniciar la eliminación del stack.\e[0m"
    exit 1
fi
set -e

# Esperar a que termine la eliminación
echo -e "\e[36mEsperando que el stack se elimine...\e[0m"
set +e
aws cloudformation wait stack-delete-complete \
    --stack-name "$STACK_NAME" \
    --region "$REGION"
if [ $? -ne 0 ]; then
    echo -e "\e[31mERROR: La eliminación del stack falló o excedió el tiempo de espera.\e[0m"
    echo -e "\e[33mVerificar manualmente en la consola de CloudFormation.\e[0m"
    exit 1
fi
set -e

# ── [4/4] Eliminar bucket de staging (Lambdas) ──────────
echo ""
echo -e "\e[36m[4/4] Eliminando bucket de staging de Lambdas...\e[0m"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
CODE_BUCKET="mariposas-dev-lambda-code-${ACCOUNT_ID}"

if aws s3 ls "s3://$CODE_BUCKET" > /dev/null 2>&1; then
    echo -e "\e[33m  Eliminando bucket: $CODE_BUCKET\e[0m"
    aws s3 rb "s3://$CODE_BUCKET" --force --region "$REGION"
    echo -e "\e[32m  Bucket de staging eliminado.\e[0m"
else
    echo -e "\e[90m  El bucket de staging no existe o ya fue eliminado.\e[0m"
fi

echo ""
echo -e "\e[32m==========================================\e[0m"
echo -e "\e[32m Stack eliminado exitosamente             \e[0m"
echo -e "\e[32m==========================================\e[0m"
echo ""
echo -e "\e[90mRecursos adicionales a eliminar manualmente:\e[0m"
echo -e "\e[90m  - Log groups de CloudWatch: /aws/lambda/mariposas-* y /aws/apigateway/mariposas-*\e[0m"
echo ""
