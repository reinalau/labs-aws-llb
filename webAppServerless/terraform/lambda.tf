# ============================================================
# lambda.tf — Funciones Lambda (4 funciones)
# ============================================================
# Cada función tiene un propósito único y bien delimitado:
#   1. GetMariposas        → GET  /mariposas
#   2. CreateMariposa      → POST /mariposas
#   3. DeleteMariposa      → DELETE /mariposas/{id}
#   4. GeneratePresignedUrl→ POST /mariposas/upload-url
#
# Los archivos fuente están en ../../src/
# Se empaquetan como .zip antes del deploy.
# ============================================================

# ── Empaquetado de los archivos fuente ─────────────────────

data "archive_file" "lambda_get" {
  type        = "zip"
  source_file = "${path.module}/../src/lambda_get_mariposas.py"
  output_path = "${path.module}/.lambda_packages/lambda_get.zip"
}

data "archive_file" "lambda_create" {
  type        = "zip"
  source_file = "${path.module}/../src/lambda_create_mariposa.py"
  output_path = "${path.module}/.lambda_packages/lambda_create.zip"
}

data "archive_file" "lambda_delete" {
  type        = "zip"
  source_file = "${path.module}/../src/lambda_delete_mariposa.py"
  output_path = "${path.module}/.lambda_packages/lambda_delete.zip"
}

data "archive_file" "lambda_presigned" {
  type        = "zip"
  source_file = "${path.module}/../src/lambda_generate_presigned_url.py"
  output_path = "${path.module}/.lambda_packages/lambda_presigned.zip"
}

# ── Variables de entorno comunes ───────────────────────────
locals {
  lambda_common_env = {
    DYNAMODB_TABLE   = aws_dynamodb_table.mariposas.name
    S3_IMAGES_BUCKET = aws_s3_bucket.images.id
    REGION           = var.aws_region
    PRESIGNED_URL_TTL = tostring(var.s3_presigned_url_ttl)
    CLOUDFRONT_URL   = "https://${aws_cloudfront_distribution.main.domain_name}"
  }
}

# ── Lambda 1: Obtener lista de avistamientos ───────────────

resource "aws_lambda_function" "get_mariposas" {
  function_name    = "${local.name_prefix}-get-mariposas"
  description      = "GET /mariposas — Retorna avistamientos de DynamoDB (requiere auth JWT)"
  role             = aws_iam_role.lambda_exec.arn
  filename         = data.archive_file.lambda_get.output_path
  source_code_hash = data.archive_file.lambda_get.output_base64sha256
  handler          = "lambda_get_mariposas.lambda_handler"
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_mb

  environment {
    variables = local.lambda_common_env
  }
}

# ── Lambda 2: Crear avistamiento (metadata) ────────────────

resource "aws_lambda_function" "create_mariposa" {
  function_name    = "${local.name_prefix}-create-mariposa"
  description      = "POST /mariposas — Persiste metadata del avistamiento en DynamoDB"
  role             = aws_iam_role.lambda_exec.arn
  filename         = data.archive_file.lambda_create.output_path
  source_code_hash = data.archive_file.lambda_create.output_base64sha256
  handler          = "lambda_create_mariposa.lambda_handler"
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_mb

  environment {
    variables = local.lambda_common_env
  }
}

# ── Lambda 3: Eliminar avistamiento ────────────────────────

resource "aws_lambda_function" "delete_mariposa" {
  function_name    = "${local.name_prefix}-delete-mariposa"
  description      = "DELETE /mariposas/{id} — Elimina item de DynamoDB e imagen de S3"
  role             = aws_iam_role.lambda_exec.arn
  filename         = data.archive_file.lambda_delete.output_path
  source_code_hash = data.archive_file.lambda_delete.output_base64sha256
  handler          = "lambda_delete_mariposa.lambda_handler"
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_mb

  environment {
    variables = local.lambda_common_env
  }
}

# ── Lambda 4: Generar URL prefirmada para S3 ───────────────

resource "aws_lambda_function" "presigned_url" {
  function_name    = "${local.name_prefix}-presigned-url"
  description      = "POST /mariposas/upload-url — Genera S3 Presigned URL para PUT de imagen"
  role             = aws_iam_role.lambda_exec.arn
  filename         = data.archive_file.lambda_presigned.output_path
  source_code_hash = data.archive_file.lambda_presigned.output_base64sha256
  handler          = "lambda_generate_presigned_url.lambda_handler"
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_mb

  environment {
    variables = local.lambda_common_env
  }
}

# ── Log Groups con retención definida ──────────────────────
# CloudFormation crea los log groups automáticamente, pero
# Terraform los crea explícitamente para controlar la retención.

resource "aws_cloudwatch_log_group" "get_mariposas" {
  name              = "/aws/lambda/${aws_lambda_function.get_mariposas.function_name}"
  retention_in_days = 1 # Reducir retención en dev para ahorrar costos
}

resource "aws_cloudwatch_log_group" "create_mariposa" {
  name              = "/aws/lambda/${aws_lambda_function.create_mariposa.function_name}"
  retention_in_days = 1
}

resource "aws_cloudwatch_log_group" "delete_mariposa" {
  name              = "/aws/lambda/${aws_lambda_function.delete_mariposa.function_name}"
  retention_in_days = 1
}

resource "aws_cloudwatch_log_group" "presigned_url" {
  name              = "/aws/lambda/${aws_lambda_function.presigned_url.function_name}"
  retention_in_days = 1
}
