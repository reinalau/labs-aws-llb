variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

variable "lambda_source_path" {
  description = "Path to lambda source code"
  type        = string
  default     = "../src"
}
