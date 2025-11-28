# Terraform - AWS EKS Fargate HA Application

La IAC despliega una aplicación web serverless de alta disponibilidad en AWS usando Terraform con EKS Fargate. Por favor, leer y entender cada .tf para estar seguros de que recursos estamos desplegando. 

❗❗ Recordar limpiar el ambiente luego de tus pruebas porque podes incurrir en costos de AWS. Seguir la guía en esta documentación.


## Prerequisitos

1. **Cuenta de AWS y AWS CLI configurado**
2. **Terraform instalado (>= 1.0)**
3. **kubectl instalado** (para gestionar el cluster Kubernetes)
Hay varias maneras de instalar, una es:
- Usando `chocolatey` en Windows:
```bash
choco install kubernetes-cli
```
4. **Docker Desktop** (para build y push de imagen a ECR)

5. **Verificar versiones instaladas**:
```bash
terraform -version
kubectl version --client
```

## 📁 Estructura del Directorio

```
terraform/
├── main.tf                  # Configuración principal y provider AWS
├── variables.tf             # Variables de entrada del proyecto
├── vpc.tf                   # VPC, subnets, routing, 2 NAT Gateways y security groups
├── alb.tf                   # Application Load Balancer y target group (IP type)
├── eks-fargate.tf           # EKS Cluster, Fargate Profile, IAM roles y security groups
├── rds.tf                   # RDS MySQL Multi-AZ con security group
├── outputs.tf               # Outputs de la infraestructura (URLs, EKS cluster)
├── terraform.tfvars.example # Ejemplo de variables de configuración
└── README.md                # Este archivo
```

## Arquitectura Serverless

- **VPC** con subnets públicas y privadas en 2 AZs
- **Application Load Balancer** en subnets públicas
- **EKS Fargate** con pods serverless en subnets privadas
- **RDS MySQL** Multi-AZ en subnets privadas
- **2 NAT Gateways** (uno por AZ) para alta disponibilidad. Ambos deben estar en las subnets publicas con salida a internet. Desde las subnet privadas se configuran las routetable para asociar con estos 2 componentes respectivamente.


![Arquitectura EKS Fargate Alta Disponibilidad](../recursos/elb-eks-fargate-rds.png)

> **📝 Nota sobre HTTPS:** Esta arquitectura usa HTTP (puerto 80). Para HTTPS necesitas un dominio propio y certificado SSL/TLS de AWS Certificate Manager (ACM) - Gratis.


## 💰 Costo Ajustado para Pruebas (4 horas)
Recurso	      Costo 4 horas	    Valor educativo
RDS Multi-AZ	$0.28	            ⭐⭐⭐⭐⭐
EKS + Fargate	$0.50	            ⭐⭐⭐⭐⭐
ALB + NAT	    $0.62	            ⭐⭐⭐
Total	        ~$1.40	                    Arquitectura completa HA

*Precios aproximados. Usar [AWS Calculator](https://calculator.aws) para estimaciones precisas.*


## Deployment

**Importante!!**
Posicionarse en la terminal en el directorio terraform: "..\labs-aws-llb\HA_ALB-EKS-RDS\terraform"

### 1. **Clonar variables**:
```bash
cp terraform.tfvars.example terraform.tfvars
```

### 2. **Editar terraform.tfvars o dejar estas por default**:
```hcl
project_name      = "aws-eks-webapp"
region            = "us-east-1"
db_username       = "admin"
db_password       = "MySecurePassword123!"
db_instance_class = "db.t3.micro"
```

### 3. **Inicializar Terraform**:
```bash
terraform init
```

### 4. **Validar configuración**:
```bash
terraform validate
```

### 5. **Planificar deployment**:
```bash
terraform plan
```

### 6. **Aplicar infraestructura**:
```bash
terraform apply
```

### 7. **Configurar kubectl**:
Una vez que el cluster EKS esté creado, configura `kubectl` para comunicarte con el cluster:

```bash
aws eks update-kubeconfig --region us-east-1 --name aws-eks-webapp-cluster
```

```bash
# Desplegar un pod de prueba
kubectl run test-pod --image=busybox -it --rm --restart=Never -- wget -O- https://www.google.com
```
✔ Si funciona, los NAT Gateways están bien configurados 


### 8. **Verificar conexión al cluster**:

```bash
kubectl cluster-info
kubectl get nodes
kubectl get pods -A
```

❕**IMPORTANTE:** 
- El deploy tarda 15-20 minutos
- EKS crea automáticamente un security group para el cluster (eks-cluster-sg-*) que es el que usan los pods
- Como estamos trabajando con Fargate no deberiamos tener nodos (nodes)
- Verifica en la consola AWS que todos los servicios estén creados antes de continuar

## Post-Deployment: Desplegar Aplicación

### 1. **Crear imagen Docker y subirla a ECR (Si estas en windws, asegurate de usar PowerShell en VisuaStudio - no cmd)**: 
```bash
# Crear repositorio ECR
aws ecr create-repository --repository-name aws-eks-webapp-repo --region us-east-1

# Build y push de imagen -Donde debes reemplazar <account-id> por el id de tu cuenta de aws!!!
export AWS_REGION="us-east-1"
aws ecr get-login-password --region us-east-1 > password.txt
cat password.txt | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
rm -f password.txt

docker build -t aws-eks-webapp-repo ../app/
docker tag aws-eks-webapp-repo:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/aws-eks-webapp-repo:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/aws-eks-webapp-repo:latest
```

### 2. **Obtener valores de Terraform**:
```bash
# Obtener valores necesarios
terraform output rds_endpoint
terraform output db_name
```

### 3. **Configurar variables de entorno**:

```bash
# Exportar variables necesarias
export ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
export DB_PASSWORD='MySecurePassword123!'  # Mismo password de terraform.tfvars
export DB_NAME="$(terraform output -raw db_name)"
export AWS_REGION="us-east-1"
export ECR_REPOSITORY="aws-eks-webapp-repo"
export DB_USER="admin"
```
Para completar el endpoint con la representacion de la ip de la base de datos, hay que ejecutar este comando y asignar la ip a la variable.

RDS_HOST=$(terraform output -raw rds_endpoint)
nslookup $RDS_HOST

Resultado similar: 
```bash
Servidor:  UnKnown
Address:  192.168.100.1

Respuesta no autoritativa:
Nombre:  aws-eks-webapp-database.cebou0ak6b7s.us-east-1.rds.amazonaws.com
Address:  10.0.3.94

*** UnKnown no encuentra RDS_ENDPOINT: Non-existent domain
```
Ejecutar el siguiente comando donde se debe reemplazar por "<..>" por la ip obtenido (en este ejemplo es 10.0.3.94) :
```bash
export RDS_ENDPOINT="<ip obtenida anteriormente>"
```


### 4. **Desplegar aplicación con variables**:
Posicionarse en el directorio raiz (donde están los .yaml)

```bash
# Aplicar manifiestos con sustitución de variables
cat deployment.yaml | \
  sed "s/\${ACCOUNT_ID}/${ACCOUNT_ID}/g" | \
  sed "s/\${AWS_REGION}/${AWS_REGION}/g" | \
  sed "s/\${ECR_REPOSITORY}/${ECR_REPOSITORY}/g" | \
  sed "s/\${RDS_ENDPOINT}/${RDS_ENDPOINT}/g" | \
  sed "s/\${DB_USER}/${DB_USER}/g" | \
  sed "s/\${DB_PASSWORD}/${DB_PASSWORD}/g" | \
  sed "s/\${DB_NAME}/${DB_NAME}/g" | \
  kubectl apply -f -

kubectl apply -f service.yaml
kubectl apply -f hpa.yaml
```

### 5. **Registrar pods en el ALB Target Group**:
Como no usamos AWS Load Balancer Controller, debemos registrar manualmente las IPs de los pods:

```bash
# Obtener IPs de los pods
kubectl get pods -o wide

# Obtener ARN del target group
TG_ARN=$(aws elbv2 describe-target-groups --names aws-eks-webapp-tg --query "TargetGroups[0].TargetGroupArn" --output text)

# Registrar las IPs de los pods (reemplaza con las IPs reales)
# Ejemplo: si tus pods tienen IPs 10.0.3.194 y 10.0.3.241
aws elbv2 register-targets --target-group-arn $TG_ARN --targets Id=10.0.3.194,Port=5000 Id=10.0.3.241,Port=5000

# Verificar que se registraron correctamente
aws elbv2 describe-target-health --target-group-arn $TG_ARN
```
**Nota Importante!**: EKS Fargate NO garantiza distribución de pods entre AZs (para este laboratorio) - Fargate decide dónde colocar los pods basándose en disponibilidad de recursos. Alta disponibilidad SIGUE funcionando porque:
El ALB está en 2 AZs (us-east-1a y us-east-1b), RDS es Multi-AZ. Si us-east-1a/1b falla, Fargate recreará los pods en us-east-1a automáticamente.

### 6. **Verificar que la aplicación funciona**:
Espera 30-60 segundos para que los health checks pasen y accede al ALB:

```bash
cd terraform
terraform output alb_url
```

Accede a la URL en tu navegador. Deberías ver la aplicación funcionando.

❗**NOTA IMPORTANTE:** Si eliminas y recreas los pods, las IPs cambiarán y deberás desregistrar las IPs viejas y registrar las nuevas en el target group (ver Troubleshooting - 6.)

## LIMPIEZA !!

### 1. **Eliminar aplicación de Kubernetes** (posicionarse en el directorio ../HA_ALB-EKS-RDS):
```bash
kubectl delete -f service.yaml
kubectl delete -f hpa.yaml
cat deployment.yaml | \
  sed "s/\${ACCOUNT_ID}/${ACCOUNT_ID}/g" | \
  sed "s/\${AWS_REGION}/${AWS_REGION}/g" | \
  sed "s/\${ECR_REPOSITORY}/${ECR_REPOSITORY}/g" | \
  sed "s/\${RDS_ENDPOINT}/${RDS_ENDPOINT}/g" | \
  sed "s/\${DB_USER}/${DB_USER}/g" | \
  sed "s/\${DB_PASSWORD}/${DB_PASSWORD}/g" | \
  sed "s/\${DB_NAME}/${DB_NAME}/g" | \
  kubectl delete -f -

```

### 2. **Destruir infraestructura con Terraform**:
```bash
cd terraform
terraform destroy
```

### 3. **ELIMINAR REPOSITORIO ECR MANUALMENTE**:
```bash
aws ecr delete-repository --repository-name aws-eks-webapp-repo --region us-east-1 --force
```

### 4. **Verificar limpieza completa**:
```bash
aws eks list-clusters --region us-east-1
aws rds describe-db-instances --region us-east-1
aws ecr describe-repositories --region us-east-1
```

### 5. **Verificar y/o Eliminar el grupo de logs en CloudWatch **
Al ejecutar terraform destroy el grupo de cloudwatch creado se elimina pero para vericarlo podemos ingresar en la consola de AWS en **CloudWatch > Log groups** con un nombre similar a "/aws/eks/aws-eks-webapp-cluster/cluster". En caso de existir eliminar para no generar costos.


## 📚 Variables Disponibles

| Variable | Descripción | Default |
|----------|-------------|----------|
| `project_name` | Nombre del proyecto | `aws-eks-webapp` |
| `region` | Región de AWS | `us-east-1` |
| `db_username` | Usuario de RDS | `admin` |
| `db_password` | Password de RDS | (requerido) |
| `db_instance_class` | Clase de instancia RDS | `db.t3.micro` |

## 🔍 Troubleshooting

**1. Error de conexión kubectl:**
```bash
aws eks update-kubeconfig --region us-east-1 --name aws-eks-webapp-cluster
```

**2. Pods no inician en Fargate:**
```bash
# Ver pods
kubectl get pods -o wide

# Ver logs
kubectl logs <pod-name>

# Describir pod
kubectl describe pod <pod-name>
```

**3. Verificar Fargate Profile:**
```bash
aws eks describe-fargate-profile --cluster-name aws-eks-webapp-cluster --fargate-profile-name aws-eks-webapp-fargate-profile
```

**4. Problemas de conectividad a RDS:**
- Verificar security groups
- Confirmar que pods están en subnets privadas
- Validar variables de entorno de conexión a DB

**5. Ver logs de EKS en CloudWatch:**
```bash
# Los logs del cluster están en CloudWatch Logs en:
# /aws/eks/aws-eks-webapp-cluster/cluster

# Ver logs desde CLI
aws logs tail /aws/eks/aws-eks-webapp-cluster/cluster --follow
```

> **💰 Nota de Costos:** Los logs se retienen solo 1 día para minimizar costos en este laboratorio educativo.

**6. Eliminar pods y volver a registrar en ALB y tambien setear ip de RDS**
Si por errores varios queremos volver a iniciar pods nuevos (sin tocar la infraestructura).

- Configurar variables con IP en lugar de hostname
```bash
export ACCOUNT_ID=(aws sts get-caller-identity --query Account --output text)
export RDS_ENDPOINT="10.0.1.254"  # IP de RDS obtenida en el punto 3
export DB_NAME="awsekswebappdatabase"
export DB_PASSWORD="MySecurePassword123!" # identica a las variables de terraforms
export AWS_REGION="us-east-1"
export ECR_REPOSITORY="aws-eks-webapp-repo"
export DB_USER="admin"
```
-Eliminar deployment actual
```bash
kubectl delete deployment aws-eks-webapp
```
-Desplegar nuevamente
```bash
cat deployment.yaml | \
  sed "s/\${ACCOUNT_ID}/${ACCOUNT_ID}/g" | \
  sed "s/\${AWS_REGION}/${AWS_REGION}/g" | \
  sed "s/\${ECR_REPOSITORY}/${ECR_REPOSITORY}/g" | \
  sed "s/\${RDS_ENDPOINT}/${RDS_ENDPOINT}/g" | \
  sed "s/\${DB_USER}/${DB_USER}/g" | \
  sed "s/\${DB_PASSWORD}/${DB_PASSWORD}/g" | \
  sed "s/\${DB_NAME}/${DB_NAME}/g" | \
  kubectl apply -f -
  ```

-Esperar a que los pods estén listos
```bash
kubectl get pods -o wide
```

-Ejecutar las instruccion una a una.
```bash
cd terraform

TG_ARN=$(aws elbv2 describe-target-groups --names aws-eks-webapp-tg --query "TargetGroups[0].TargetGroupArn" --output text)

# Desregistrar IPs viejas (reemplazar <..> por las correctas)
aws elbv2 deregister-targets --target-group-arn $TG_ARN --targets Id=<10.0.3.45>,Port=5000 Id=<10.0.3.43>,Port=5000

# Esperar a que los nuevos pods estén listos
cd ..
kubectl get pods -o wide

# Registrar las NUEVAS IPs (reemplaza con las IPs reales de los nuevos pods obtenidos de consulta anterior)
aws elbv2 register-targets --target-group-arn $TG_ARN --targets Id=<NUEVA_IP_1>,Port=5000 Id=<NUEVA_IP_2>,Port=5000

# Verificar
aws elbv2 describe-target-health --target-group-arn $TG_ARN
```
En la ultima verificación se van a visualizar los targets **healthy** y las que se estan eliminando en estado **draining** 
