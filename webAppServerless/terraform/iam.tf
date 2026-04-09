# ============================================================
# iam.tf — Roles y políticas IAM para Lambda
# ============================================================
# Un único rol de ejecución compartido por todas las Lambdas
# con el principio de mínimo privilegio:
#   - DynamoDB: operaciones sobre la tabla de mariposas
#   - S3: generación de presigned URLs + acceso al bucket imágenes
#   - CloudWatch Logs: escritura de logs (estándar Lambda)
# ============================================================

# ── Rol de ejecución Lambda ────────────────────────────────

resource "aws_iam_role" "lambda_exec" {
  name        = "${local.name_prefix}-lambda-exec-role"
  description = "Rol de ejecución para las funciones Lambda de Mariposas"

  # Trust policy: solo Lambda puede asumir este rol
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# ── Política: DynamoDB ─────────────────────────────────────
# Acceso mínimo necesario: solo sobre la tabla de mariposas

resource "aws_iam_policy" "lambda_dynamodb" {
  name        = "${local.name_prefix}-lambda-dynamodb-policy"
  description = "Permite a Lambda operar sobre la tabla DynamoDB de mariposas"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:UpdateItem"
        ]
        Resource = [
          aws_dynamodb_table.mariposas.arn,
          "${aws_dynamodb_table.mariposas.arn}/index/*" # Acceso a GSIs
        ]
      }
    ]
  })
}

# ── Política: S3 Imágenes (Presigned URL + lectura) ────────
# Solo sobre el bucket de imágenes, no el de frontend

resource "aws_iam_policy" "lambda_s3_images" {
  name        = "${local.name_prefix}-lambda-s3-images-policy"
  description = "Permite a Lambda generar presigned URLs y leer imágenes"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",       # Para generar presigned URL de PUT
          "s3:GetObject",       # Para lectura/verificación
          "s3:DeleteObject"     # Para eliminar imagen al borrar avistamiento
        ]
        Resource = "${aws_s3_bucket.images.arn}/uploads/*"
      },
      {
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = aws_s3_bucket.images.arn
      }
    ]
  })
}

# ── Política: CloudWatch Logs ──────────────────────────────
# Permite a Lambda escribir sus logs (require básico)

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ── Adjuntar políticas custom al rol ──────────────────────

resource "aws_iam_role_policy_attachment" "lambda_dynamodb" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_dynamodb.arn
}

resource "aws_iam_role_policy_attachment" "lambda_s3_images" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_s3_images.arn
}
