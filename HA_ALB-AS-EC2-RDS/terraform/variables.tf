variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "aws-ha-webapp"
}

variable "region" {
  description = "Region de AWS"
  type        = string
  default     = "us-east-1"
}

variable "key_pair_name" {
  description = "Nombre del key pair para EC2"
  type        = string
}

variable "db_username" {
  description = "Usuario de la base de datos"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Password de la base de datos"
  type        = string
  sensitive   = true
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3.micro"
}

variable "db_instance_class" {
  description = "Clase de instancia RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "s3_bucket" {
  description = "Bucket S3 donde está la imagen Docker"
  type        = string
}

variable "docker_image_name" {
  description = "Nombre del archivo Docker en S3"
  type        = string
  default     = "aws-ha-webapp.tar.gz"
}