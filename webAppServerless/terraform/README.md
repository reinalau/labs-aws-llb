# Deploy con Terraform — Paso a Paso

Esta carpeta contiene la infraestructura de Mariposas Bonaerenses definida en Terraform, separada por archivos de recursos para facilitar la comprensión y el mantenimiento.

---

## Pre-Requisitos

- **Terraform** >= 1.5.0 instalado: https://developer.hashicorp.com/terraform/install
- **AWS CLI** configurado: `aws configure`
- **Node.js** 18+ instalado (para el build del frontend)
- Permisos IAM suficientes: `s3:*`, `cloudformation:*`, `lambda:*`, `dynamodb:*`, `cognito-idp:*`, `apigateway:*`, `cloudfront:*`, `iam:PassRole`, `logs:*`

---

## Archivos del Stack

Cada archivo tiene una única responsabilidad (un servicio AWS):

| Archivo | Qué crea |
| :--- | :--- |
| `main.tf` | Provider AWS, backend de estado, locals y sufijo único para nombres de bucket |
| `variables.tf` | Parámetros configurables: región, entorno, timeouts, memoria Lambda |
| `s3.tf` | Bucket del frontend (privado, OAC) + bucket de imágenes de usuarios (CORS + OAC Policy) |
| `cloudfront.tf` | Distribución CDN con OAC (Origin Access Control) para servir tanto el frontend como las imágenes |
| `cognito.tf` | User Pool de usuarios + App Client sin secret (SPA pública) |
| `dynamodb.tf` | Tabla de avistamientos + 2 GSIs (por ecorregión y por usuario) |
| `iam.tf` | Rol Lambda con políticas de mínimo privilegio |
| `lambda.tf` | 4 funciones Lambda + log groups con 7 días de retención |
| `apigateway.tf` | REST API + Cognito Authorizer + 4 rutas + CORS por recurso |
| `outputs.tf` | URLs, IDs y comandos útiles al finalizar el deploy |
| `modules/cors/` | Módulo reutilizable para responder OPTIONS (CORS preflight) |

---

## Paso a Paso

### 1. Buildear el frontend

```bash
cd ../frontend/app
npm install
npm run build
cd ../../terraform
```

### 2. Inicializar Terraform

Descarga los providers (AWS, random) y prepara el directorio de trabajo.

```bash
terraform init
```

### 3. Revisar las variables (opcional)

Los valores por defecto están pensados para un entorno `dev` en `us-east-1`.
Para cambiarlos sin editar el código, crear un archivo `terraform.tfvars`:

```hcl
# terraform.tfvars (no commitear al repo)
aws_region  = "us-east-1"
environment = "dev"
```

> **📌 Nota sobre los nombres de Buckets S3:**  
> Notarás que el nombre exacto de tus buckets **no** se define como texto libre dentro de las variables. Esto se hace intencionalmente porque AWS S3 exige que los nombres sean globalmente únicos en toda la plataforma mundial. Para garantizar que tu despliegue nunca falle por colisión de nombres, el archivo `main.tf` incorpora un bloque de `random_id` que le anexa un sufijo aleatorio a los buckets en forma automática (Ejemplo: `mariposas-dev-frontend-a4b2c89d`). Su nombre final te lo dirá Terraform en los _Outputs_.

### 4. Validar la configuración

```bash
terraform validate
```

### 5. Ver el plan de cambios

Muestra todos los recursos que se van a crear **sin aplicar nada**.

```bash
terraform plan
```

> 💡 Leer el plan antes de aplicar es una buena práctica. Permite entender qué se va a crear/modificar/eliminar.

### 6. Aplicar el plan (crear la infraestructura)

```bash
terraform apply
```

Terraform pedirá confirmación. Escribir `yes` y presionar Enter.

> ⏱️ El proceso tarda entre **5 y 10 minutos**, principalmente por CloudFront y Cognito.

### 7. Ver los outputs

Al finalizar el `apply`, Terraform muestra los outputs automáticamente. Para verlos de nuevo:

```bash
terraform output
```

Los outputs incluyen:
- `cloudfront_url` → URL del sitio web
- `api_gateway_url` → URL de la API (para el frontend)
- `cognito_user_pool_id` → ID del User Pool
- `cognito_client_id` → ID del App Client
- `frontend_bucket_name` → Nombre del bucket para subir el frontend
- `deploy_frontend_command` → Comando listo para copiar y ejecutar

### 8. Subir el frontend al bucket S3

Terraform muestra el comando exacto en el output `deploy_frontend_command`. O ejecutar:

```bash
aws s3 sync ../frontend/app/dist/ s3://$(terraform output -raw frontend_bucket_name) --delete
```

### 9. Acceder al sitio

Usar la URL de `cloudfront_url`. La propagación de CloudFront puede tardar **1-2 minutos**.

---

## 🔁 Actualizar la infraestructura

Ante cualquier cambio en los archivos `.tf`, repetir los pasos 4, 5 y 6.
Terraform detecta solo los cambios y aplica el mínimo necesario.

Para actualizar el código de las Lambdas sin tocar la infraestructura:

```bash
terraform apply -target=aws_lambda_function.get_mariposas
# o aplicar todos los cambios normalmente
terraform apply
```

---

## 🧹 Eliminar todos los recursos

```bash
terraform destroy
```

Terraform pedirá confirmación. Escribir `yes`.

> ⚠️ Los buckets S3 con `force_destroy = true` (configurado en `s3.tf`) se vacían y eliminan automáticamente. No hace falta vaciarlos a mano.

---

## 🔐 Seguridad de Imágenes (CloudFront OAC)

Para que las imágenes se visualicen correctamente en la web, el stack implementa una arquitectura segura:
1. **Buckets Privados**: S3 tiene bloqueado todo el acceso público.
2. **OAC (Origin Access Control)**: CloudFront se identifica ante S3 usando firmas SigV4.
3. **Bucket Policy**: En `s3.tf`, el recurso `aws_s3_bucket_policy.images` autoriza específicamente a la distribución de CloudFront para ejecutar `s3:GetObject` sobre los archivos de la carpeta `uploads/`.

Si las imágenes no se visualizan después de un deploy desde cero, verificar que se haya ejecutado el `terraform apply` completo para que estas políticas de bucket queden activas.

---

Después del destroy, eliminar manualmente:
- Los Log Groups de CloudWatch (no son eliminados por Terraform por defecto)
- El directorio `.terraform/` si no se va a seguir usando

---

## 📁 Archivos ignorados por Git

El `.gitignore` del proyecto excluye:
- `terraform.tfstate` y backups → contienen información sensible de los recursos creados
- `.terraform/` → carpeta de providers (se regenera con `terraform init`)
- `.lambda_packages/` → zips temporales de las Lambdas
- `*.tfvars` → pueden contener valores sensibles

---

## 🔍 Comandos útiles de diagnóstico

```bash
# Ver el estado actual de los recursos
terraform show

# Ver solo un recurso específico
terraform state show aws_dynamodb_table.mariposas

# Aplicar solo un recurso (útil al iterar)
terraform apply -target=aws_lambda_function.get_mariposas

# Ver los outputs sin aplicar cambios
terraform output
```
