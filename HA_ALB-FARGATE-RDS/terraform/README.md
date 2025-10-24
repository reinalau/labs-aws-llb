# Terraform - AWS ECS Fargate HA Application

La IAC despliega una aplicación web serverless de alta disponibilidad en AWS usando Terraform con ECS Fargate.

❗❗ Recordar limpiar el ambiente luego de tus pruebas porque podes incurrir en costos de AWS. Seguir la guía en esta documentación.


## Prerequisitos

1. **Cuenta de AWS y AWS CLI configurado**
2. **Terraform instalado (>= 1.0)**
3. **Docker Desktop** (para build y push de imagen a ECR)

```bash
terraform -version
```

4. **Importante!!**
Posicionarse en la terminal en el directorio terraform: "..\labs-aws-llb\HA_ALB-FARGATE-RDS\terraform"

## 📁 Estructura del Directorio

```
terraform/
├── main.tf                  # Configuración principal y provider AWS
├── variables.tf             # Variables de entrada del proyecto
├── vpc.tf                   # VPC, subnets, routing, 2 NAT Gateways y security groups
├── alb.tf                   # Application Load Balancer y target group (IP type)
├── ecs-fargate.tf           # ECS Cluster, Task Definition, Service y Auto Scaling
├── rds.tf                   # RDS MySQL Multi-AZ con security group
├── outputs.tf               # Outputs de la infraestructura (URLs, ECR, ECS)
├── terraform.tfvars.example # Ejemplo de variables de configuración
├── ecr-push.sh              # Script para build Docker y push a ECR
└── README.md                # Este archivo
```

## Arquitectura Serverless

- **VPC** con subnets públicas y privadas en 2 AZs
- **Application Load Balancer** en subnets públicas
- **ECS Fargate Service** con tareas serverless en subnets privadas (Min: 2, Max: 6)
- **RDS MySQL** Multi-AZ en subnets privadas
- **2 NAT Gateways** (uno por AZ) para alta disponibilidad
- **Amazon ECR** para almacenar imágenes Docker

![Arquitectura ECS Fargate Alta Disponibilidad](./recursos/ELB-ECSFARGATE-RDS.png)

> **📝 Nota sobre HTTPS:** Esta arquitectura usa HTTP (puerto 80). Para HTTPS necesitas un dominio propio y certificado SSL/TLS de AWS Certificate Manager (ACM) - Gratis.


## Deployment

### 1. **Build y Push de imagen Docker a ECR**:

Este script construirá la imagen Docker y la subirá a Amazon ECR.
El primer parametro:"aws-ha-webapp" es el nombre del proyecto que debe coincidir con las variables de terraform (archivo terraform.tvars)

```bash
chmod +x ecr-push.sh
./ecr-push.sh aws-ha-webapp us-east-1
```

**Parámetros:**
- `aws-ha-webapp` → Nombre del proyecto
- `us-east-1` → Región de AWS (opcional, usa AWS_DEFAULT_REGION si no se especifica)

### 2. **Clonar variables**:
```bash
cp terraform.tfvars.example terraform.tfvars
```

### 3. **Editar terraform.tfvars**:
```hcl
project_name = "aws-ha-webapp"
db_password  = "MiPasswordSeguro123!"
region       = "us-east-1"
```

### 4. **Inicializar Terraform**:
```bash
terraform init
```

### 5. **Validar configuración**:
```bash
terraform validate
```

### 6. **Planificar deployment**:
```bash
terraform plan
```

### 7. **Aplicar infraestructura**:
```bash
terraform apply
```

### 8. **Obtener outputs**:
```bash
terraform output alb_url
terraform output ecr_repository_url
terraform output ecs_cluster_name
```

❕**IMPORTANTE:** 
- El deploy puede tardar de 10 a 15 minutos. 
- Ingresar a la consola de AWS y verificar los servicios creados.
- La URL del ALB se presenta en el output como:
  `alb_url = "http://aws-ha-webapp-alb-xxxxx.us-east-1.elb.amazonaws.com"`
- Los servicios pueden tardar unos minutos en inicializarse
- Verificar en la consola: **ECS → Clusters → Services → Tasks**

## Limpieza

### 1. **Destruir infraestructura con Terraform**:
```bash
terraform destroy
```

**⚠️ Importante**: `terraform destroy` elimina VPC, ECS, RDS, ALB y NAT Gateways, pero **NO elimina el repositorio ECR** porque fue creado manualmente por el script.

### 2. **Eliminar repositorio ECR manualmente** (Requerido):

El repositorio ECR debe eliminarse manualmente porque no fue creado por Terraform:

```bash
# Opción 1: Eliminar repositorio con todas las imágenes (--force)
aws ecr delete-repository --repository-name aws-ha-webapp-repo --region us-east-1 --force

# Opción 2: Eliminar imágenes primero, luego el repositorio
aws ecr batch-delete-image --repository-name aws-ha-webapp-repo --region us-east-1 --image-ids imageTag=latest

aws ecr delete-repository --repository-name aws-ha-webapp-repo --region us-east-1
```

### 3. **Verificar limpieza completa**:
```bash
# Verificar que no queden recursos
aws ecr describe-repositories --region us-east-1
aws ecs list-clusters --region us-east-1
aws rds describe-db-instances --region us-east-1
```

## 💰 Estimación de Costos (us-east-1)

| Recurso | Tipo | Cantidad | Costo/mes (aprox) |
|---------|------|----------|-------------------|
| Fargate | 0.25 vCPU, 0.5 GB | 2 tareas 24/7 | ~$15.00 |
| RDS | db.t3.micro Multi-AZ | 1 | $25.00 |
| ALB | - | 1 | $22.50 |
| NAT Gateway | - | 2 | $90.00 |
| ECR | Storage | ~100 MB | $0.01 |
| CloudWatch Logs | 1 GB | - | $0.50 |
| **Total** | | | **~$153/mes** |

*Precios aproximados. Usar [AWS Calculator](https://calculator.aws) para estimaciones precisas.*

## 📚 Variables Disponibles

| Variable | Descripción | Default |
|----------|-------------|----------|
| `project_name` | Nombre del proyecto | `aws-ha-webapp` |
| `region` | Región de AWS | `us-east-1` |
| `db_username` | Usuario de RDS | `admin` |
| `db_password` | Password de RDS | (requerido) |
| `db_instance_class` | Clase de instancia RDS | `db.t3.micro` |

## 🔍 Troubleshooting

**1. Error de autenticación ECR:**
```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
```

**2. Tareas Fargate no inician:**
```bash
# Ver logs del servicio
aws ecs describe-services --cluster aws-ha-webapp-cluster --services aws-ha-webapp-service

# Ver logs de CloudWatch
aws logs tail /ecs/aws-ha-webapp --follow
```

**3. Actualizar imagen Docker:**
```bash
# Rebuild y push
./ecr-push.sh aws-ha-webapp us-east-1

# Forzar nuevo deployment
aws ecs update-service --cluster aws-ha-webapp-cluster --service aws-ha-webapp-service --force-new-deployment
```

