# Deploy con CloudFormation — Paso a Paso

Esta carpeta contiene el template CloudFormation completo para desplegar la infraestructura de Mariposas Bonaerenses.

---

## Pre-Requisitos

- AWS CLI configurado: `aws configure`
- Node.js 18+ instalado (para el build del frontend)
- Permisos IAM: `s3:*`, `cloudformation:*`, `lambda:*`, `dynamodb:*`, `cognito-idp:*`, `apigateway:*`, `cloudfront:*`, `iam:PassRole`, `logs:*`

---

## ⚡ Opción automática (script)

Si preferís automatizar todos los pasos anteriores, podés usar el script incluido:

```bash
./deploy.sh
```

> El script realiza los pasos 1 al 7 de forma automática. Revisarlo antes de ejecutar para entender qué hace.

Para Limpieza automatica:
```bash
./delete-cloudformation.sh
```

## 🚶‍♀️ Paso a Paso Manual

### 1. Buildear el frontend

```bash
cd ../frontend/app
npm install
npm run build
cd ../../cloudformation
```

### 2. Crear el bucket para el código Lambda

CloudFormation necesita que los `.zip` de las Lambdas existan en S3 antes de crear el stack.

```bash
# Reemplazar ACCOUNT_ID con tu Account ID de AWS
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
LAMBDA_BUCKET="mariposas-dev-lambda-code-$ACCOUNT_ID"
REGION="us-east-1"

aws s3 mb s3://$LAMBDA_BUCKET --region $REGION
```

### 3. Empaquetar y subir las funciones Lambda

> **Recomendación:** Este paso suele dar errores en Windows si no tenés `zip` instalado. El script `./deploy.sh` ya lo hace por vos usando Python.

Si decidís hacerlo manual:

```bash
cd ../src

# Empaquetar cada función (Usando Python para máxima compatibilidad)
python -c "import zipfile; zipfile.ZipFile('lambda_get_mariposas.zip', 'w', zipfile.ZIP_DEFLATED).write('lambda_get_mariposas.py', 'lambda_get_mariposas.py')"
python -c "import zipfile; zipfile.ZipFile('lambda_create_mariposa.zip', 'w', zipfile.ZIP_DEFLATED).write('lambda_create_mariposa.py', 'lambda_create_mariposa.py')"
python -c "import zipfile; zipfile.ZipFile('lambda_delete_mariposa.zip', 'w', zipfile.ZIP_DEFLATED).write('lambda_delete_mariposa.py', 'lambda_delete_mariposa.py')"
python -c "import zipfile; zipfile.ZipFile('lambda_generate_presigned_url.zip', 'w', zipfile.ZIP_DEFLATED).write('lambda_generate_presigned_url.py', 'lambda_generate_presigned_url.py')"

# Subir los .zip al bucket
aws s3 cp . --region $REGION --recursive --exclude "*" --include "*.zip" --target s3://$LAMBDA_BUCKET/

cd ../cloudformation
```

### 4. Validar el template

```bash
aws cloudformation validate-template \
    --template-body file://template.yaml \
    --region $REGION
```

### 5. Crear el stack

```bash
aws cloudformation deploy \
    --template-file template.yaml \
    --stack-name mariposas-webapp \
    --parameter-overrides Environment=dev \
    --capabilities CAPABILITY_NAMED_IAM \
    --region $REGION \
    --no-fail-on-empty-changeset
```

> ⏱️ Este proceso tarda entre **5 y 10 minutos**. Se puede seguir el progreso en la consola de AWS → CloudFormation.

### 6. Ver los outputs del stack

```bash
aws cloudformation describe-stacks \
    --stack-name mariposas-webapp \
    --region $REGION \
    --query "Stacks[0].Outputs[*].{Key:OutputKey,Value:OutputValue}" \
    --output table
```

Los outputs incluyen:
- `CloudFrontURL` → URL del sitio web
- `ApiGatewayURL` → URL de la API (para el frontend)
- `CognitoUserPoolId` → ID del User Pool
- `CognitoClientId` → ID del App Client
- `FrontendBucketName` → Nombre del bucket para subir el frontend

### 7. Subir el frontend al bucket S3

```bash
# Obtener el nombre del bucket desde los outputs
FRONTEND_BUCKET=$(aws cloudformation describe-stacks \
    --stack-name mariposas-webapp \
    --region $REGION \
    --query "Stacks[0].Outputs[?OutputKey=='FrontendBucketName'].OutputValue" \
    --output text)

# Sincronizar el build del frontend
aws s3 sync ../frontend/app/dist/ s3://$FRONTEND_BUCKET --delete --region $REGION
```

### 8. Acceder al sitio

Usar la URL de `CloudFrontURL` del paso 6. La propagación de CloudFront puede tardar **1-2 minutos**.

---

## 🔁 Actualizar el stack (cambios posteriores)

Repetir los pasos 3, 4 y 5. CloudFormation detecta los cambios y aplica solo lo necesario.

---

## 🧹 Eliminar todos los recursos

```bash
# Vaciar los buckets S3 primero (CloudFormation no puede eliminarlos con objetos)
FRONTEND_BUCKET=$(aws cloudformation describe-stacks \
    --stack-name mariposas-webapp --region $REGION \
    --query "Stacks[0].Outputs[?OutputKey=='FrontendBucketName'].OutputValue" --output text)

IMAGES_BUCKET=$(aws cloudformation describe-stacks \
    --stack-name mariposas-webapp --region $REGION \
    --query "Stacks[0].Outputs[?OutputKey=='ImagesBucketName'].OutputValue" --output text)

aws s3 rm s3://$FRONTEND_BUCKET --recursive --region $REGION
aws s3 rm s3://$IMAGES_BUCKET   --recursive --region $REGION

# Eliminar el stack
aws cloudformation delete-stack --stack-name mariposas-webapp --region $REGION

# Esperar que termine
aws cloudformation wait stack-delete-complete --stack-name mariposas-webapp --region $REGION
```

También eliminar manualmente:
- El bucket de código Lambda: `aws s3 rb s3://$LAMBDA_BUCKET --force`
- Los Log Groups de CloudWatch (desde la consola o con AWS CLI)

---


