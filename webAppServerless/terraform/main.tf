# ============================================================
# main.tf — Provider, backend y locals
# ============================================================
# Configuración base: proveedor AWS, backend de estado y
# valores locales reutilizables en todos los módulos.
# ============================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # Opcional: descomentar para usar backend remoto en S3
  # backend "s3" {
  #   bucket = "mi-terraform-state-bucket"
  #   key    = "mariposas-webapp/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "mariposas-webapp"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# Sufijo aleatorio para garantizar nombres únicos de buckets S3
resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  # Nombre base del proyecto usado en todos los recursos
  name_prefix = "mariposas-${var.environment}"

  # Sufijo único para buckets S3 (nombres globales únicos)
  unique_suffix = random_id.suffix.hex

  # Nombre de la tabla DynamoDB
  dynamodb_table_name = "${local.name_prefix}-mariposas"

  # Nombre del bucket de imágenes de usuarios
  images_bucket_name = "${local.name_prefix}-images-${local.unique_suffix}"

  # Nombre del bucket del frontend
  frontend_bucket_name = "${local.name_prefix}-frontend-${local.unique_suffix}"
}
