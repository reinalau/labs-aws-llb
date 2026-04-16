# Requerimientos Worker Fleet
## Escalado Automático Basado en Profundidad de Cola SQS

> **Documento de Requerimientos Funcionales**

| Campo | Valor |
|---|---|
| Versión | 1.0 |
| Tipo de documento | Requerimientos Funcionales |
| Servicios AWS | SQS, EC2, Auto Scaling, CloudWatch, IAM |
| Nivel | Intermedio |
| Costo estimado | < $0.10 USD por hora de práctica |
| IaC soportado | CloudFormation / Terraform (implementación separada) |

---

## 1. Objetivo del Laboratorio

Este laboratorio tiene como fin enseñar el patrón de arquitectura **Worker Fleet** en AWS, donde una flota de instancias EC2 consume mensajes de una cola SQS de forma autónoma, y el grupo de autoescalado ajusta dinámicamente la cantidad de instancias en función de la **profundidad de esa queue.**

Al finalizar el laboratorio aprenderás a:

- Crear y configurar una cola SQS estándar.
- Desplegar un Auto Scaling Group (ASG) con una Launch Template.
- Configurar una alarma de CloudWatch que use la métrica `ApproximateNumberOfMessagesVisible`.
- Vincular la alarma a una Scaling Policy del ASG para escalar horizontalmente.
- Verificar el comportamiento del sistema enviando carga a la cola y observando el escalado.
- Validar el Health Check de las instancias EC2 dentro del ASG.

---

## 2. Arquitectura del Sistema

### 2.1 Diagrama de Flujo

```
Generador de carga  →  Cola SQS  →  CloudWatch Alarm  →  ASG Scaling Policy  →  Flota EC2 (workers)
                            ↑
               ApproximateNumberOfMessagesVisible
```

### 2.2 Descripción del Patrón

Se trata del patrón **Worker Fleet**. Cada instancia EC2 del ASG ejecuta un proceso en loop continuo que hace polling a SQS mediante la API `ReceiveMessage`. Cuando la cola acumula mensajes por encima de un umbral configurado, CloudWatch dispara una alarma que ordena al ASG lanzar más instancias. Cuando la cola se vacía, el ASG hace scale-in y termina las instancias sobrantes.

El **visibility timeout** de SQS garantiza que un mismo mensaje solo sea procesado por una instancia a la vez. Si la instancia falla antes de eliminar el mensaje, este vuelve a estar visible para el resto de la flota. Este parametro es configurable.

---

## 3. Componentes a Crear

### 3.1 Cola SQS

| Parámetro | Valor recomendado | Descripción |
|---|---|---|
| Tipo de cola | Standard Queue | Mayor throughput, entrega at-least-once |
| Visibility Timeout | 30 segundos | Tiempo que el mensaje queda oculto mientras se procesa |
| Message Retention | 4 horas | Suficiente para el lab; evita acumulación |
| Max Receive Count (DLQ) | 3 intentos | Si el worker falla 3 veces, el mensaje va a la Dead Letter Queue |
| Dead Letter Queue | Recomendada | Cola separada para mensajes que no pudieron procesarse |

### 3.2 Launch Template

La Launch Template define la configuración de cada instancia EC2 que el ASG lanzará. Debe incluir:

- **AMI:** Amazon Linux 2023 (última versión disponible en la región).
- **Instance Type:** t3.micro (elegible para Free Tier).
- **IAM Instance Profile:** Rol con permisos mínimos sobre SQS (`ReceiveMessage`, `DeleteMessage`, `GetQueueAttributes`).
- **User Data:** Script de arranque que instala las dependencias e inicia el proceso worker en loop.
- **Security Group:** Sin inbound público requerido; solo outbound HTTPS para llamadas a la API de AWS.
- **Etiquetas (Tags):** `Name`, `Environment=lab-llb`, `Project=sqs-asg-lab` para identificación.

### 3.3 Auto Scaling Group (ASG)

| Parámetro | Valor recomendado | Descripción |
|---|---|---|
| Min Instances | 1 | Siempre hay al menos un worker activo |
| Max Instances | 4 | Techo para controlar el costo del lab |
| Desired Capacity | 1 | Capacidad inicial al arrancar |
| Health Check Type | EC2 | Verifica el estado de la instancia a nivel de hipervisor |
| Health Check Grace Period | 120 segundos | Tiempo para que la instancia arranque antes de evaluar salud |
| Cooldown Period | 120 segundos | Pausa entre eventos de escalado para evitar oscilación |
| Availability Zones | Mínimo 2 AZs | Alta disponibilidad dentro de la región |

### 3.4 Scaling Policies

Se deben crear dos políticas independientes sobre el ASG:

#### Scale-Out Policy (agregar instancias)

- **Tipo:** Step Scaling o Simple Scaling.
- **Condición:** `ApproximateNumberOfMessagesVisible >= 10` mensajes durante 2 períodos de evaluación.
- **Acción:** Agregar 1 instancia al ASG.

#### Scale-In Policy (remover instancias)

- **Tipo:** Step Scaling o Simple Scaling.
- **Condición:** `ApproximateNumberOfMessagesVisible <= 1` mensaje durante 3 períodos de evaluación.
- **Acción:** Remover 1 instancia del ASG (respetando Min Instances).

### 3.5 CloudWatch Alarms

Se necesitan al menos dos alarmas de CloudWatch, una por política:

| Parámetro | Scale-Out Alarm | Scale-In Alarm |
|---|---|---|
| Namespace | AWS/SQS | AWS/SQS |
| Métrica | ApproximateNumberOfMessagesVisible | ApproximateNumberOfMessagesVisible |
| Operador | GreaterThanOrEqualToThreshold | LessThanOrEqualToThreshold |
| Threshold | 10 | 1 |
| Period | 60 segundos | 60 segundos |
| Evaluation Periods | 2 | 3 |
| Statistic | Maximum | Maximum |

### 3.6 IAM Role para EC2

Crear un IAM Role con la política mínima necesaria. Los permisos requeridos sobre el recurso de la cola SQS son:

- `sqs:ReceiveMessage`
- `sqs:DeleteMessage`
- `sqs:GetQueueAttributes`
- `sqs:GetQueueUrl`

Adicionalmente, para que las instancias puedan escribir logs en CloudWatch Logs (opcional pero recomendado):

- `logs:CreateLogGroup`
- `logs:CreateLogStream`
- `logs:PutLogEvents`

---

## 4. Proceso Worker en las EC2

El User Data de la Launch Template debe dejar corriendo en cada instancia un proceso worker con la siguiente lógica:

1. La instancia inicia y el User Data instala Python 3 y boto3 (o el SDK equivalente).
2. El script worker arranca como servicio o proceso en background.
3. El worker entra en un loop continuo llamando a `ReceiveMessage` con `MaxNumberOfMessages=10` y `WaitTimeSeconds=20` (long polling).
4. Por cada mensaje recibido, ejecuta el procesamiento simulado (por ejemplo, un `sleep` de 2 a 5 segundos).
5. Tras procesar exitosamente, llama a `DeleteMessage` para eliminar el mensaje de la cola.
6. Si ocurre un error, el mensaje expira su visibility timeout y vuelve a la cola para ser reintentado.

> **Nota:** El tiempo de sleep en el procesamiento es clave para el laboratorio. Si el worker procesa demasiado rápido, la cola se vacía antes de que se active la alarma de CloudWatch y el escalado no se aprecia visualmente.

---

## 5. Health Check

### 5.1 EC2 Health Check (nativo del ASG)

El ASG monitorea el estado de cada instancia usando el health check a nivel EC2. Una instancia se marca como `unhealthy` si:

- La instancia está en estado `stopped`, `terminated`, `shutting-down` o `impaired` según el hipervisor de AWS.
- El status check de la instancia falla (System Status Check o Instance Status Check).

Cuando el ASG detecta una instancia unhealthy, la termina automáticamente y lanza una nueva en su reemplazo, manteniendo la Desired Capacity.

### 5.2 Validación Manual del Health Check

Durante el laboratorio se puede forzar un escenario de instancia unhealthy para validar el comportamiento:

1. Identificar el Instance ID de una instancia del ASG.
2. Ejecutar el siguiente comando para marcarla manualmente como unhealthy:

```bash
aws autoscaling set-instance-health \
  --instance-id <i-xxxx> \
  --health-status Unhealthy
```

3. Observar en el ASG cómo la instancia es terminada y se lanza una nueva.
4. Verificar con el comando:

```bash
aws autoscaling describe-auto-scaling-instances \
  --instance-ids <i-xxxx>
```

---

## 6. Procedimiento de Prueba

### Paso 1 — Verificar estado inicial

Antes de enviar carga, validar que el ASG tiene exactamente 1 instancia en estado `InService` y que la cola SQS está vacía.

```bash
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names <nombre-asg>

aws sqs get-queue-attributes \
  --queue-url <url-cola> \
  --attribute-names ApproximateNumberOfMessagesVisible
```

### Paso 2 — Enviar carga a la cola

Usar el script de carga del repositorio para enviar entre 50 y 200 mensajes. Este volumen garantiza que la alarma se active y haya tiempo de observar el escalado antes de que la cola se vacíe.

```bash
aws sqs send-message-batch \
  --queue-url <url-cola> \
  --entries file://mensajes.json
```

### Paso 3 — Monitorear la profundidad de cola por CLI

En una terminal aparte, ejecutar en loop para ver cómo crece la cola:

```bash
watch -n 5 aws sqs get-queue-attributes \
  --queue-url <url-cola> \
  --attribute-names ApproximateNumberOfMessagesVisible
```

### Paso 4 — Monitorear el ASG por CLI

En otra terminal, observar cómo el número de instancias `InService` aumenta:

```bash
watch -n 10 aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names <nombre-asg> \
  --query 'AutoScalingGroups[0].Instances[*].{ID:InstanceId,Estado:HealthStatus,Lifecycle:LifecycleState}'
```

### Paso 5 — Observar en CloudWatch Console

Navegar en la consola AWS a **CloudWatch → Metrics → SQS** y agregar al dashboard:

- `SQS > ApproximateNumberOfMessagesVisible` — profundidad de la cola en el tiempo.
- `EC2/AutoScaling > GroupInServiceInstances` — cantidad de instancias activas en el ASG.

Podrás ver ambas gráficas en simultáneo y observar la correlación: cuando la primera sube, la segunda sube algunos minutos después; cuando la primera baja a cero, la segunda baja al mínimo configurado.

### Paso 6 — Validar el Scale-In

Una vez que todos los mensajes fueron procesados y la cola llega a 0, esperar el tiempo definido en los Evaluation Periods de la alarma de Scale-In (3 períodos × 60 segundos ≈ 3 minutos) más el Cooldown. El ASG debe reducir instancias hasta llegar a `Min Instances = 1`.

### Paso 7 — Validar el Health Check

Con el ASG en estado estable, ejecutar el escenario de instancia unhealthy descrito en la [sección 5.2](#52-validación-manual-del-health-check) y verificar la recuperación automática.

---

## 7. Criterios de Éxito del Laboratorio

| Criterio | Resultado esperado | Cómo verificarlo |
|---|---|---|
| Cola recibe mensajes | `ApproximateNumberOfMessagesVisible > 0` | CLI / CloudWatch |
| Alarma Scale-Out se activa | Estado `ALARM` en CloudWatch | CloudWatch Alarms |
| ASG lanza instancias | `GroupInServiceInstances` aumenta | CLI / CloudWatch |
| Workers consumen la cola | Mensajes visibles disminuyen | CLI / CloudWatch |
| Cola llega a 0 | `ApproximateNumberOfMessagesVisible = 0` | CLI / CloudWatch |
| Alarma Scale-In se activa | Estado `ALARM` en CloudWatch | CloudWatch Alarms |
| ASG reduce instancias | `GroupInServiceInstances` vuelve a 1 | CLI / CloudWatch |
| Health Check recupera instancia | Nueva instancia reemplaza a la unhealthy | CLI describe-instances |

---

## 8. Estructura Actual del Repositorio Git

```text
sqs-asg-ec2/
├── README.md                  ← Guía paso a paso principal
├── requerimientos.md          ← Este documento (Arquitectura y métricas)
├── cloudformation/
│   └── template.yaml          ← Plantilla IaC nativa de AWS
├── terraform/                 ← Código IaC modular de HashiCorp
│   ├── asg.tf                 
│   ├── cloudwatch.tf          
│   ├── iam.tf                 
│   ├── outputs.tf             
│   ├── providers.tf           
│   ├── sqs.tf                 
│   └── variables.tf           
├── scripts/
│   ├── send_load.py           ← Generador de carga Python para testear la SQS
│   └── worker.py              ← Script referencial del código inyectado en EC2
└── resources/                 ← Assets y diagramas visuales
    ├── arq-workers.png
    ├── sqs-asg-fleet.jpg
    └── sqs-asg-fleet.xml
```

---

## 9. Consideraciones Adicionales

### 9.1 Limpieza de Recursos

Al finalizar el laboratorio es obligatorio destruir todos los recursos creados para evitar costos inesperados. El orden recomendado de eliminación es:

1. Instancias EC2 (via ASG: set desired/min/max = 0)
2. Auto Scaling Group
3. Launch Template
4. CloudWatch Alarms
5. Cola SQS (y Dead Letter Queue)
6. IAM Role e Instance Profile

### 9.2 Región

Se recomienda usar **us-east-1** (Norte de Virginia) por tener mayor disponibilidad de tipos de instancia en el Free Tier.

### 9.3 Costo Estimado

Con instancias `t3.micro` y una duración de laboratorio de 1 a 2 horas, el costo estimado es **menor a $0.10 USD**, considerando que SQS y CloudWatch básico caen dentro del Free Tier mensual.

### 9.4 Implementación con IaC

La implementación con CloudFormation o Terraform se define en documentos separados dentro del directorio `iac/` del repositorio. Este documento cubre únicamente los requerimientos funcionales y la arquitectura conceptual.

---

*Requerimientos de Laboratorio AWS Educativo — SQS + Auto Scaling Group by reinalau 💚*
