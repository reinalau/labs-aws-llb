![AWS](https://img.shields.io/badge/AWS-232F3E?style=flat&logo=amazonaws&logoColor=white)
![Serverless](https://img.shields.io/badge/Serverless-FD5750?style=flat&logo=serverless&logoColor=white)
![React](https://img.shields.io/badge/React-20232A?style=flat&logo=react&logoColor=61DAFB)

## WebApp Serverless 3 Capas: Mariposas Bonaerenses Nativas

Laboratorio educativo de una aplicación web serverless completa sobre mariposas nativas de la provincia de Buenos Aires-Argentina.
Implementa una arquitectura de **3 capas serverless en AWS**: Web Tier (S3 + CloudFront), App Tier (Cognito + API Gateway + Lambda) y Data Tier (DynamoDB + S3 imágenes).

El objetivo es construir una aplicación real con autenticación, subida de archivos y CRUD completo utilizando solo servicios serverless de AWS, deployable con CloudFormation o Terraform.

## 🏗️ Arquitectura

![Arquitectura 3 Capas](recursos/AppServerlessArquitectura.png)

Ver documentación detallada del flujo en [Arquitectura.md](Arquitectura.md)

## Estructura del Proyecto

```
borrador_webAppServerless/
├── cloudformation/
│   ├── template.yaml                  ← Stack completo (todos los recursos)
│   ├── deploy.sh                      ← Script de despliegue (Bash)
│   └── delete-cloudformation.sh       ← Script de limpieza (Bash)
├── terraform/
│   ├── main.tf                        ← Provider, locals, backend
│   ├── variables.tf                   ← Variables de entrada
│   ├── outputs.tf                     ← Salidas del stack
│   ├── s3.tf                          ← Buckets S3 (frontend + imágenes)
│   ├── cloudfront.tf                  ← Distribución CloudFront + OAC
│   ├── cognito.tf                     ← User Pool + App Client
│   ├── dynamodb.tf                    ← Tabla Mariposas + GSIs
│   ├── iam.tf                         ← Roles y políticas IAM
│   ├── lambda.tf                      ← Funciones Lambda
│   └── apigateway.tf                  ← REST API + Cognito Authorizer
├── src/
│   ├── lambda_get_mariposas.py        ← GET /mariposas
│   ├── lambda_create_mariposa.py      ← POST /mariposas
│   ├── lambda_delete_mariposa.py      ← DELETE /mariposas/{id}
│   └── lambda_generate_presigned_url.py ← POST /mariposas/upload-url
├── frontend/
│   └── app/                           ← React + Vite + TypeScript
├── recursos/
│   └── *.pdf                          ← Material de referencia sobre mariposas
├── Arquitectura.md
└── README.md
```

## ⚙️ Funcionalidades

| Feature | Usuario anónimo | Usuario logueado |
| :--- | :---: | :---: |
| Ver catálogo de mariposas precargadas | ✅ | ✅ |
| Ver galería de avistamientos de usuarios | ❌ | ✅ |
| Subir foto + metadata de avistamiento | ❌ | ✅ |
| Filtrar por ecorregión | ✅ | ✅ |
| Ver ficha detallada de mariposa | ✅ | ✅ |

## 🔗 Endpoints API

| Método | Path | Auth | Descripción |
| :--- | :--- | :--- | :--- |
| `GET` | `/mariposas` | JWT (Cognito) | Listar avistamientos de usuarios |
| `POST` | `/mariposas` | JWT (Cognito) | Crear registro + metadata en DynamoDB |
| `DELETE` | `/mariposas/{id}` | JWT (Cognito) | Eliminar propio avistamiento |
| `POST` | `/mariposas/upload-url` | JWT (Cognito) | Obtener URL prefirmada para subir imagen a S3 |


## Pre-Requisitos

- Una AWS account con credenciales configuradas (`aws configure`)
- Permisos IAM suficientes: `s3:*`, `cloudformation:*`, `lambda:*`, `dynamodb:*`, `cognito-idp:*`, `apigateway:*`, `cloudfront:*`, `iam:PassRole`, `logs:*`
- Node.js 18+ y npm (para buildear el frontend)

- Para desplegar con **Terraform** → tener instalado Terraform:
  https://developer.hashicorp.com/terraform/install

- Para desplegar con **CloudFormation** → solo necesitás AWS CLI:
  https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html

- Puedes verificar las versiones con:
Python en mi caso tengo 3.14.2 (compatible con las anteriores)
```bash
python --version
```
Terraform en Windows v1.14.8
```bash
terraform --version
```
Cli de AWS tengo aws-cli/2.26.2
```bash
aws --version
```

## 💰 Costo Estimado del Laboratorio

> Todos los servicios usados en este lab están **dentro del Free Tier de AWS** para pruebas normales.

### Free Tier cubierto (primeros 12 meses + always-free)

| Servicio | Free Tier | Uso estimado en lab | Costo |
| :--- | :--- | :--- | :--- |
| **S3** | 5 GB storage, 20K GET, 2K PUT | < 100MB, < 100 requests | $0.00 |
| **CloudFront** | 1 TB transfer, 10M requests/mes | < 1GB, < 10K requests | $0.00 |
| **Cognito** | 50,000 MAU (always free) | 1-5 usuarios de prueba | $0.00 |
| **API Gateway** | 1M calls/mes (12 meses) | < 500 llamadas | $0.00 |
| **Lambda** | 1M requests + 400K GB-seg/mes | < 1000 invocaciones | $0.00 |
| **DynamoDB** | 25 GB + 25 RCU + 25 WCU (always free) | < 1MB, < 10 operaciones | $0.00 |

### 💡 Costo estimado total de una sesión de lab (deploy → probar → destruir)
> **~$0.00 a $0.05 USD**

### ⚠️ Si se deja el laboratorio ejecutando (sin destruir, sin free tier)

| Servicio | Costo mensual estimado |
| :--- | :--- |
| S3 (frontend + imágenes) | ~$0.02 |
| CloudFront (mínimo tráfico) | ~$0.50 |
| API Gateway | ~$0.01 |
| Lambda | ~$0.00 |
| DynamoDB (on-demand) | ~$0.25 |
| Cognito (< 50K MAU) | $0.00 |
| **Total mensual** | **~$0.80 - $1.50 USD/mes** |

> **Recomendación:** Destruir todos los recursos al terminar las pruebas para evitar costos.
> Ver sección [🧹 Limpieza](#-limpieza-de-ambiente) más abajo.

### 🌐 ¿Y Route53?

Este laboratorio **no utiliza Route53**. La aplicación es accesible directamente por la URL autogenerada por CloudFront (ej: `https://dj97ayik5evb0.cloudfront.net`), lo cual es perfectamente funcional para un entorno educativo.

Route53 solo tendría sentido en **producción real** donde se requiere un dominio personalizado. En ese caso, los componentes y costos adicionales serían:

| Componente | Descripción | Costo estimado |
| :--- | :--- | :--- |
| **Route53 Hosted Zone** | Zona DNS para tu dominio | ~$0.50/mes |
| **Dominio personalizado** | Ej: `mariposas.tudominio.com` | ~$12-15/año |
| **Certificado ACM (SSL)** | HTTPS con dominio propio en CloudFront | **Gratis** |

> Para pasar a producción con dominio propio, se debería: registrar el dominio → crear una Hosted Zone en Route53 → emitir un certificado ACM en `us-east-1` → asociarlo a la distribución de CloudFront → crear un registro `ALIAS` en Route53 apuntando a CloudFront.

## Ejecución local de la web sin backend
```bash
cd frontend/app
npm run dev
# El resultado queda en frontend/app/dist/
```
Ingresar al puerto que indica. 
Puedes cambiarlo si quisieras como: 
```bash
cd frontend/app
npm run dev -- --port 3000
```

0 de esta forma:
En el archivo vite.config.ts (ubicado en frontend/app/vite.config.ts).
Debes agregar la propiedad server con el puerto deseado dentro de defineConfig. Ejemplo para usar el puerto 3000:

```
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
  }
})

```

## 🚀 Opciones de Deployment

El deploy de la infraestructura se puede realizar de 2 maneras. Se recomienda leer los componentes de la infraestructura segun el modo, **comprender la IaC antes probar ambas.**

### Preparar el Frontend (paso previo para todas las opciones de deployment)

```bash
cd frontend/app
npm install      # Instala dependencias, incluyendo el SDK de Amazon Cognito
npm run build
# El resultado queda en frontend/app/dist/
```

---

### Opción 1: CloudFormation

👉 **Instrucciones completas y manuales en [cloudformation/README.md](cloudformation/README.md)**

Forma rápida (con el script automatizado):
```bash
cd cloudformation
./deploy.sh
```

Limpiar ambiente:
```bash
./delete-cloudformation.sh
```

---

### Opción 2: Terraform

👉 **Estructura de archivos detallada e instrucciones completas en [terraform/README.md](terraform/README.md)**

Comandos rápidos:
```bash
cd terraform
terraform init
terraform validate
terraform plan
terraform apply
```

Cuidado!! con este destruyes la infra (Limpiar ambiente):
```bash
terraform destroy
```

---

### 🔌 PASO SIGUIENTE: Conectar el Frontend con el Backend

Una vez que el sitio carga correctamente en CloudFront, **la app aún no tiene funcionalidad real** hasta que se configure la integración con Cognito, API Gateway y S3.

👉 **Instrucciones completas paso a paso en [integration.md](integration.md) luego vuelve a este punto del README para seguir el paso a paso**

Allí encontrarás:
- Cómo actualizar `aws-config.ts` con los valores de tus Outputs
- Cómo crear un usuario en AWS Cognito (consola o CLI)
- El flujo técnico completo de autenticación y subida de datos
- Troubleshooting de errores comunes

### PASO FINAL: Deploy del Frontend a S3 con la integracion

Para evitar confusiones posicionarse en la carpeta del proyecto (webAppServerless)
Luego de crear la infraestructura (por cualquier método) y conectar el backend, subir el build del frontend al bucket S3 (frontend_bucket_name):

```bash
# Reemplazar frontend_bucket_name con el output del deployment
aws s3 sync frontend/app/dist/ s3://frontend_bucket_name --delete
```
Puedes hacer este paso sin conectar el backend con el frontend pero no vas a tener funcionalidad.

**¡IMPORTANTE! Si estás actualizando un Front-end ya subido:** 
CloudFront mantendrá la versión vieja en su sistema de caché y tu web podría verse en blanco o rota tras el sync. Para solucionarlo debes limpiar su caché invadiéndolo:
```bash
aws cloudfront create-invalidation --distribution-id TU_CLOUDFRONT_DISTRIBUTION_ID --paths "/*"
```
 *(Tanto tu ID como el comando exacto aparecerán al instante en los Outputs de tu consola al hacer `terraform apply`).*

Acceder al sitio por la URL de CloudFront que aparece en los outputs del stack o impresion de script de cloudformation. (La url es similar a : https://d1eiqubwoqnf6p.cloudfront.net/)

---


### 👤 Crear usuario en Cognito

La web **no tiene pantalla de auto-registro**. Los usuarios deben crearse manualmente.
Los datos de TU_USER_POOL_ID se obtienen del ouput de Terraform por ejemplo.

**Opción A: AWS CLI**
```bash
# 1. Crear el usuario
aws cognito-idp admin-create-user \
  --user-pool-id TU_USER_POOL_ID \
  --username reinalau@email.com \
  --user-attributes Name=email,Value=reinalau@email.com Name=email_verified,Value=true

# 2. Establecer contraseña permanente (evita el forced-change al primer login)
aws cognito-idp admin-set-user-password \
  --user-pool-id TU_USER_POOL_ID \
  --username reinalau@email.com \
  --password "Mariposas!2027!" \
  --permanent
```
> Reemplazar `TU_USER_POOL_ID` con el valor del output `cognito_user_pool_id`.

**Opción B: Consola de AWS**

1. Ir a **Amazon Cognito → User Pools → `mariposas-dev-users`**
2. Pestaña **Users → Create user**
3. Completar Email y contraseña permanente

---

## Iniciar sesión en la app

Con el usuario creado, abrís la app en el navegador, hacés click en **"Iniciar Sesión"** (botón de la Navbar) e ingresás las credenciales del usuario que creaste.

Al autenticarte, el JWT de Cognito se guarda automáticamente en el `localStorage` del navegador y se restaura al recargar la página.

## 📊 Monitoreo

### CloudWatch Logs

Los logs de cada Lambda se almacenan automáticamente en CloudWatch:

- `/aws/lambda/mariposas-get`
- `/aws/lambda/mariposas-create`
- `/aws/lambda/mariposas-delete`
- `/aws/lambda/mariposas-presigned-url`


## 🧹 Limpieza de Ambiente

> ⚠️ Recordar destruir todos los recursos para evitar costos.

**Con CloudFormation:**
```bash
cd cloudformation
./delete-cloudformation.sh
```

**Con Terraform:**
```bash
cd terraform
terraform destroy
```

**Manual adicional:**
- Vaciar y eliminar los buckets S3 manualmente si CloudFormation/Terraform falla (los buckets con objetos no se eliminan automáticamente).
- Eliminar los log groups de CloudWatch desde la consola.


## 🚀 Trabajos Futuro

Este laboratorio es una base sólida, pero puede evolucionar con las siguientes mejoras:

1.  **Privacidad Avanzada**: Implementar **CloudFront Signed URLs o Cookies** para restringir el acceso a las imágenes de modo que solo el usuario que la subió (o usuarios autorizados) pueda ver el archivo original.
2.  **Auto-registro (Self Sign-Up)**: Habilitar el flujo de registro en Cognito y crear la pantalla de "Crear Cuenta" en el frontend para eliminar la dependencia de la consola/CLI.
3.  **Inteligencia Artificial**: Integrar **Amazon Rekognition** en la arquitectura para validar automáticamente que la imagen subida contenga una mariposa antes de guardarla en DynamoDB.
4.  **Dominio Propio**: Configurar Route53 y certificados ACM para usar un dominio personalizado.
5.  **Búsqueda Avanzada**: Implementar **Amazon OpenSearch** para permitir búsquedas complejas por texto libre en las descripciones.


## 📄 Licencia

Este proyecto está bajo la Licencia MIT.
