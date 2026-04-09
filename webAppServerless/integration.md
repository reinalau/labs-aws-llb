# 🔌 Integración Frontend ↔ AWS Backend

Este documento explica cómo el frontend React se conecta con la infraestructura AWS desplegada (Cognito, API Gateway, Lambda, DynamoDB y S3).

---

## ¿Qué necesito antes de empezar?

1-Haber completado el **deploy de la infraestructura** con Terraform o CloudFormation y tener a mano los **Outputs** del stack. Con Terraform los obtenés así:

```bash
cd terraform
terraform output
```
2-En Cloudformarion los obtenes consultando el stack, pero deberias haber tomado nota si elegiste está opción al ejecutar el script o el paso: 

```bash
aws cloudformation describe-stacks --stack-name mariposas-webapp --region us-east-1
```
Los valores que necesitarás son:

| Output | Descripción |
|---|---|
| `cognito_user_pool_id` | ID del User Pool de Cognito |
| `cognito_client_id` | ID del App Client de Cognito |
| `api_gateway_url` | URL base de la REST API |
| `cloudfront_url` | URL pública de la distribución CloudFront |

---

## Paso 1: Configurar `aws-config.ts`

Abre el archivo `frontend/app/src/aws-config.ts` y reemplaza los valores con los de tus propios Outputs:

```typescript
export const awsConfig = {
  cognito: {
    userPoolId: 'us-east-1_TU_USER_POOL_ID',   // ← cognito_user_pool_id
    clientId:   'TU_CLIENT_ID',                  // ← cognito_client_id
    region:     'us-east-1',
  },
  apiUrl:        'https://TU_API_ID.execute-api.us-east-1.amazonaws.com/dev',  // ← api_gateway_url
  cloudfrontUrl: 'https://TU_CLOUDFRONT_ID.cloudfront.net',                   // ← cloudfront_url
};
```

> ⚠️ **Este archivo ya viene con los valores del deploy inicial**. Solo necesitás editarlo si hacés un nuevo `terraform apply` que genere una nueva infraestructura.

Hacer el build para que la carpeta dist tome los cambios de la integración.

``` bash
cd frontend/app
npm run build
```

---

IMPORTANTE! Seguir con la instruccion del  README.md principal **"PASO FINAL: Deploy del Frontend a S3 con la integracion"**


## INFO ADICIONAL: Flujo técnico de los datos

### Login
```
[Browser] → CognitoUserPool.authenticateUser() → [AWS Cognito]
                                                       ↓
                                               JWT (IdToken)
                                                       ↓
                                         Guardado en localStorage
```

### Cargar avistamientos de mariposas (GET)
```
[Browser] → GET /mariposas (Authorization: Bearer JWT)
                 ↓
          [API Gateway] → valida JWT con Cognito Authorizer
                 ↓
           [Lambda: GetMariposas]
                 ↓
           [DynamoDB Query]
                 ↓
           JSON con la lista de mariposas
```

### Subir nueva mariposa (POST con imagen)
```
[Browser] → POST /mariposas/upload-url (JWT)
                 ↓
          [Lambda: GeneratePresignedUrl]
                 ↓
           Presigned URL + imageKey
                 ↓
[Browser] → PUT imagen directo a S3 (sin pasar por Lambda)
                 ↓
[Browser] → POST /mariposas con metadata + imageKey (JWT)
                 ↓
          [Lambda: CreateMariposa]
                 ↓
           PutItem en DynamoDB
```

> La imagen se sube **directamente a S3** usando la Presigned URL que esta guardada en DynamoDB para evitar el límite de 6MB de payload de Lambda/API Gateway.

---

## Archivos clave del frontend

| Archivo | Responsabilidad |
|---|---|
| `src/aws-config.ts` | Centraliza los valores de los outputs de Terraform |
| `src/context/AuthContext.tsx` | Login/logout/sesión real con Cognito |
| `src/hooks/useMariposas.ts` | Carga y subida de datos a la API |
| `src/components/LoginModal.tsx` | UI del formulario de login |
| `src/sections/UploadSection.tsx` | Sección de subida, muestra al usuario logueado |
| `src/components/UploadMariposaForm.tsx` | Formulario de alta de mariposa |

---

## Troubleshooting frecuente

| Síntoma | Causa probable | Solución |
|---|---|---|
| "Incorrect username or password" | Contraseña temporal no cambiada | Usar `admin-set-user-password --permanent` desde CLI |
| 401 Unauthorized en la API | JWT vencido (1h por defecto) | Cerrar sesión y volver a loguearse |
| CORS error en el upload | Bucket S3 sin CORS configurado | `terraform apply` regenera la config CORS |
| Imagen no se ve en CloudFront | URL de imagen incorrecta | Revisar que `imageKey` empiece por `uploads/` |
| 403 en CloudFront al ver imagen | OAC no configurado para imágenes | Verificar `aws_s3_bucket_policy.images` en Terraform |
