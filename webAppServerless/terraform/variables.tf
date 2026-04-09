# ============================================================
# variables.tf — Variables de entrada del stack
# ============================================================
# Todos los parámetros configurables del laboratorio.
# Los valores por defecto están pensados para un entorno dev.
# ============================================================

variable "aws_region" {
  description = "Región AWS donde se despliegan los recursos"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Entorno de despliegue (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "El entorno debe ser dev, staging o prod."
  }
}

variable "cognito_user_pool_name" {
  description = "Nombre del Cognito User Pool"
  type        = string
  default     = "mariposas-users"
}

variable "lambda_runtime" {
  description = "Runtime de las funciones Lambda"
  type        = string
  default     = "python3.12"
}

variable "lambda_timeout" {
  description = "Timeout de las funciones Lambda en segundos"
  type        = number
  default     = 29
}

variable "lambda_memory_mb" {
  description = "Memoria asignada a cada función Lambda en MB"
  type        = number
  default     = 256
}

variable "dynamodb_billing_mode" {
  description = "Modo de facturación de DynamoDB (PAY_PER_REQUEST o PROVISIONED)"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "s3_presigned_url_ttl" {
  description = "TTL en segundos para las URLs prefirmadas de S3 (subida de imágenes)"
  type        = number
  default     = 300
}

variable "cloudfront_price_class" {
  description = "Clase de precio de CloudFront (PriceClass_100 = solo US+Europa, más barato)"
  type        = string
  default     = "PriceClass_100"
}
