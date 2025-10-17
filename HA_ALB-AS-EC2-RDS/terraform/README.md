# Terraform - AWS HA Web Application

La IAC despliega una aplicación web de alta disponibilidad en AWS usando Terraform.

❗❗ Recordar limpiar el ambiente luego de tus pruebas porque podes incurrir en costos de aws. Seguir la guia en esta documentación.


## Prerequisitos

1. **Cuenta de AWS y AWS CLI configurado**
2. **Terraform instalado. Verificar version.**
3. **Docker Desktop (para empaquetar la aplicacion y subirla a s3)**

```bash
terraform -version
```

3. **Key pair creado en AWS EC2 (debajo esta el paso para crearlo)**
4. **Importante!!**
Posicionarse en la terminal en el directorio terraform: "..\labs-aws-llb\HA_ALB-AS-EC2-RDS\terraform"

## 📁 Estructura del Directorio

```
terraform/
├── main.tf                  # Configuración principal, provider AWS y AMI específica
├── variables.tf             # Variables de entrada del proyecto
├── vpc.tf                   # VPC, subnets, routing, NAT Gateway y security groups
├── alb.tf                   # Application Load Balancer y target group
├── ec2.tf                   # Launch template, Auto Scaling, IAM roles y CloudWatch
├── rds.tf                   # RDS MySQL Multi-AZ con security group
├── outputs.tf               # Outputs de la infraestructura (URLs, endpoints)
├── terraform.tfvars.example # Ejemplo de variables de configuración
├── docker-construct-tf.sh   # Script para build Docker y upload a S3
├── user_data.sh             # Script de inicialización para el template instancias EC2
└── README.md                # Este archivo
```

## Arquitectura

- **VPC** con subnets públicas y privadas en 2 AZs
- **Application Load Balancer** en subnets públicas
- **Auto Scaling Group** con EC2 en subnets privadas (Min: 2, Max: 6)
- **RDS MySQL** Multi-AZ en subnets privadas
- **NAT Gateway** para acceso a internet desde subnets privadas

![Arquitectura Alta Disponibilidad Tradicional](recursos/ELB-AS-RDS.png)


## Deployment

1. 🔑 Crear Key Pair (Requerido-si ya lo tienes no es necesario crearlo)

```bash
# Crear key pair en AWS
aws ec2 create-key-pair --key-name mi-keypair --query 'KeyMaterial' --output text > mi-keypair.pem
chmod 400 mi-keypair.pem

# Verificar que existe
aws ec2 describe-key-pairs --key-names mi-keypair
```
En el directorio actual se bajará una llave con nombre similar: mi-keypair.pem

2. **Construir y subir imagen Docker a un S3**:
Los parametros son : aws-ha-webapp --> project-name y bucket-terraform-llb--> buckect-name
Importante! En aws los nombres de los buckets deben ser unicos. Es probable que si lo que pasemos ya exista rompa el script. Recomiendo poner las iniciales tu nombre en lugar de "llb".
Este script construirá la imagen Docker para luego crear/subir a S3 y te dará los valores para terraform.tfvars.

```bash
./docker-construct-tf.sh aws-ha-webapp bucket-terraform-llb
```

3. **Clonar variables**:
```bash
cp terraform.tfvars.example terraform.tfvars
```

4. **Editar terraform.tfvars** con los valores del paso 1:
```bash
project_name      = "mi-proyecto"
key_pair_name    = "mi-keypair"
db_password      = "MiPasswordSeguro123!"
s3_bucket        = "aws-ha-webapp-docker-1234567890"  # Del script
docker_image_name = "aws-ha-webapp.tar.gz"            # Del script
```

5. **Inicializar Terraform**:

❕Importante: Revisar los valores del archivo terraform.tfvars. Ejemplo: nombre del bucket tiene que corresponder con el bucket creado anteriormente, al igual que el nombre del Proyecto.

```bash
terraform init
```

6. **Validar configuración**:
```bash
terraform validate
```

7. **Planificar deployment**:
```bash
terraform plan
```

8. **Aplicar infraestructura**:
```bash
terraform apply
```

9. **Obtener URL de la aplicación**:
```bash
terraform output alb_url
```
❕Importante: 
    -Ingresar a la consola de aws y verificar los servicios y features creados.
    -La url del ALB para visualizra la aplicacion se presenta en el ouput como:
        " alb_url = "http://aws-ha-webapp-alb-908897033.us-east-1.elb.amazonaws.com" "
    -Los servicios pueden estar inicializandose y por eso la url del outpu anterior no funciona inmediatamente. Verificar en la consola de EC2!!

## Limpieza

1. **Destruir infraestructura**:
```bash
terraform destroy
```

2. **Eliminar bucket S3 manualmente -  reemplazar por tu nombre de bucket**:
```bash
# Vaciar bucket
aws s3 rm s3://tu-bucket-name --recursive

# Eliminar bucket 
aws s3 rb s3://tu-bucket-name
```

**Nota**: Terraform no elimina automáticamente el bucket S3 con contenido, debe eliminarse manualmente con el punto anterior.

