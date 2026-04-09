#!/bin/bash
# ============================================================
# deploy.sh — Despliega el stack de Mariposas en AWS vía CloudFormation
# ============================================================
# Este script:
#   1. Valida el template CloudFormation
#   2. Crea o actualiza el stack con todos los recursos AWS
#   3. Muestra los outputs (URLs, IDs) necesarios para configurar el frontend
#
# Prerrequisitos:
#   - AWS CLI configurado (aws configure) con permisos suficientes
#   - Node.js 18+ instalado (para buildear el frontend)
#
# Uso:
#   ./deploy.sh
# ============================================================

set -e # Terminar en caso de error

ENVIRONMENT="dev"
REGION="us-east-1"
STACK_NAME="mariposas-webapp"

echo ""
echo -e "\e[36m==========================================\e[0m"
echo -e "\e[36m Mariposas Bonaerenses — CloudFormation   \e[0m"
echo -e "\e[36m==========================================\e[0m"
echo -e "\e[33m Stack      : $STACK_NAME\e[0m"
echo -e "\e[33m Environment: $ENVIRONMENT\e[0m"
echo -e "\e[33m Region     : $REGION\e[0m"
echo ""

SCRIPT_DIR=$(dirname "$0")
TEMPLATE_FILE="$SCRIPT_DIR/template.yaml"

# ── [1/4] Buildear el frontend ────────────────────────────
echo -e "\e[36m[1/4] Buildeando el frontend React...\e[0m"
FRONTEND_PATH="$SCRIPT_DIR/../frontend/app"

if [ ! -d "$FRONTEND_PATH" ]; then
    echo -e "\e[33mWARN: No se encontró la carpeta frontend/app. Saltando build.\e[0m"
else
    cd "$FRONTEND_PATH"
    npm install --silent
    npm run build --silent
    cd - > /dev/null
    echo -e "\e[32mFrontend buildeado correctamente.\e[0m"
fi

# ── [2/4] Preparar código de Lambdas ──────────────────────
echo -e "\e[36m[2/4] Obteniendo Account ID y preparando Lambdas...\e[0m"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
CODE_BUCKET="mariposas-${ENVIRONMENT}-lambda-code-${ACCOUNT_ID}"
SRC_PATH="$SCRIPT_DIR/../src"

# Crear bucket de código si no existe
if ! aws s3 ls "s3://$CODE_BUCKET" > /dev/null 2>&1; then
    echo -e "\e[33mCreando bucket de staging: $CODE_BUCKET\e[0m"
    aws s3 mb "s3://$CODE_BUCKET" --region "$REGION"
fi

# Empaquetar y subir cada Lambda
echo "Empaquetando funciones..."
for func in lambda_create_mariposa lambda_delete_mariposa lambda_generate_presigned_url lambda_get_mariposas; do
    if [ -f "$SRC_PATH/$func.py" ]; then
        # Usamos Python para hacer el zip (más compatible en Windows si no hay 'zip' instalado)
        python -c "import zipfile; zipfile.ZipFile('$SCRIPT_DIR/$func.zip', 'w', zipfile.ZIP_DEFLATED).write('$SRC_PATH/$func.py', '$func.py')"
        aws s3 cp "$SCRIPT_DIR/$func.zip" "s3://$CODE_BUCKET/$func.zip" --quiet
        rm "$SCRIPT_DIR/$func.zip"
    else
        echo -e "\e[31mERROR: No se encontró $func.py en $SRC_PATH\e[0m"
        exit 1
    fi
done
echo -e "\e[32mCódigo de Lambdas subido a S3.\e[0m"

# ── [3/4] Validar el template ─────────────────────────────
echo ""
echo -e "\e[36m[3/4] Validando el template CloudFormation...\e[0m"

if ! aws cloudformation validate-template \
    --template-body "file://$TEMPLATE_FILE" \
    --region "$REGION" > /dev/null; then
    echo -e "\e[31mERROR: El template CloudFormation no es válido.\e[0m"
    exit 1
fi
echo -e "\e[32mTemplate válido.\e[0m"

# ── [4/4] Deploy del stack ────────────────────────────────
echo ""
echo -e "\e[36m[4/4] Deployando stack (esto puede tardar 5-10 minutos)...\e[0m"

set +e 
aws cloudformation deploy \
    --template-file "$TEMPLATE_FILE" \
    --stack-name "$STACK_NAME" \
    --parameter-overrides Environment="$ENVIRONMENT" \
    --capabilities CAPABILITY_NAMED_IAM \
    --region "$REGION" \
    --no-fail-on-empty-changeset

DEPLOY_STATUS=$?
set -e

if [ $DEPLOY_STATUS -ne 0 ]; then
    echo ""
    echo -e "\e[31mERROR: El deployment falló. Ver eventos del stack:\e[0m"
    echo -e "\e[33m  aws cloudformation describe-stack-events --stack-name $STACK_NAME --region $REGION\e[0m"
    exit 1
fi

echo -e "\e[32mStack deployado exitosamente.\e[0m"

# ── [5/5] Obtener outputs y sincronizar frontend ──────────
echo ""
echo -e "\e[36m[5/5] Obteniendo outputs del stack...\e[0m"

FRONTEND_BUCKET=$(aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --region "$REGION" \
    --query "Stacks[0].Outputs[?OutputKey=='FrontendBucketName'].OutputValue" \
    --output text)

CLOUDFRONT_URL=$(aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --region "$REGION" \
    --query "Stacks[0].Outputs[?OutputKey=='CloudFrontURL'].OutputValue" \
    --output text)

API_URL=$(aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --region "$REGION" \
    --query "Stacks[0].Outputs[?OutputKey=='ApiGatewayURL'].OutputValue" \
    --output text)

USER_POOL_ID=$(aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --region "$REGION" \
    --query "Stacks[0].Outputs[?OutputKey=='CognitoUserPoolId'].OutputValue" \
    --output text)

CLIENT_ID=$(aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --region "$REGION" \
    --query "Stacks[0].Outputs[?OutputKey=='CognitoClientId'].OutputValue" \
    --output text)

DISTRIBUTION_ID=$(aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --region "$REGION" \
    --query "Stacks[0].Outputs[?OutputKey=='CloudFrontDistributionId'].OutputValue" \
    --output text)

# Subir el frontend al bucket S3 (si se buildeó)
DIST_PATH="$SCRIPT_DIR/../frontend/app/dist"
if [ -d "$DIST_PATH" ] && [ -n "$FRONTEND_BUCKET" ]; then
    echo -e "\e[36mSubiendo frontend a S3 bucket: $FRONTEND_BUCKET\e[0m"
    aws s3 sync "$DIST_PATH" "s3://$FRONTEND_BUCKET" --delete --region "$REGION"
    echo -e "\e[32mFrontend subido correctamente.\e[0m"
fi

# ── Resumen final ─────────────────────────────────────────
echo ""
echo -e "\e[32m==========================================\e[0m"
echo -e "\e[32m DEPLOYMENT EXITOSO\e[0m"
echo -e "\e[32m==========================================\e[0m"
echo ""
echo -e "\e[36m 🌐 Sitio Web (CloudFront):\e[0m"
echo -e "    $CLOUDFRONT_URL"
echo ""
echo -e "\e[36m 🆔 CloudFront Distribution ID:\e[0m"
echo -e "    $DISTRIBUTION_ID"
echo ""
echo -e "\e[36m 🗄️  S3 Frontend Bucket:\e[0m"
echo -e "    $FRONTEND_BUCKET"
echo ""
echo -e "\e[36m 🔗 API Gateway URL:\e[0m"
echo -e "    $API_URL"
echo ""
echo -e "\e[36m 🔐 Cognito User Pool ID:\e[0m"
echo -e "    $USER_POOL_ID"
echo ""
echo -e "\e[36m 🔑 Cognito Client ID:\e[0m"
echo -e "    $CLIENT_ID"
echo ""
echo -e "\e[90m Configurar en el frontend (frontend/app/.env.local):\e[0m"
echo -e "\e[90m   VITE_API_URL=$API_URL\e[0m"
echo -e "\e[90m   VITE_COGNITO_USER_POOL_ID=$USER_POOL_ID\e[0m"
echo -e "\e[90m   VITE_COGNITO_CLIENT_ID=$CLIENT_ID\e[0m"
echo -e "\e[90m   VITE_CLOUDFRONT_URL=$CLOUDFRONT_URL\e[0m"
echo ""
