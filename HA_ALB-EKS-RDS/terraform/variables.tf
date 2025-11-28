variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "aws-eks-webapp"
}

variable "region" {
  description = "Region de AWS"
  type        = string
  default     = "us-east-1"
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

variable "db_instance_class" {
  description = "Clase de instancia RDS"
  type        = string
  default     = "db.t3.micro"
}