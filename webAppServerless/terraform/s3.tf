# ============================================================
# s3.tf — Buckets S3: Frontend estático + Imágenes de usuarios
# ============================================================
# Dos buckets con roles distintos:
#   1. Frontend: sirve la SPA React vía CloudFront (privado, OAC)
#   2. Imágenes: almacena fotos subidas por usuarios (privado,
#      acceso solo vía Presigned URL generada por Lambda)
# ============================================================

# ── Bucket: Frontend (SPA React) ───────────────────────────

resource "aws_s3_bucket" "frontend" {
  bucket        = local.frontend_bucket_name
  force_destroy = true # Permite destruir aunque tenga objetos (útil en lab)

  tags = {
    Name = "${local.name_prefix}-frontend"
    Role = "static-website"
  }
}

# Bloqueo de acceso público (CloudFront accede por OAC, no por URL pública)
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Configuración de versionado (opcional, útil para rollbacks del frontend)
resource "aws_s3_bucket_versioning" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  versioning_configuration {
    status = "Disabled" # Habilitarlo en prod si se quieren rollbacks
  }
}

# Política: permite solo a CloudFront (OAC) leer los objetos
resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontOAC"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.frontend.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.main.arn
          }
        }
      }
    ]
  })

  depends_on = [aws_cloudfront_distribution.main]
}

# ── Bucket: Imágenes de usuarios ───────────────────────────

resource "aws_s3_bucket" "images" {
  bucket        = local.images_bucket_name
  force_destroy = true

  tags = {
    Name = "${local.name_prefix}-images"
    Role = "user-uploads"
  }
}

# Bloqueo de acceso público (acceso solo vía Presigned URL)
resource "aws_s3_bucket_public_access_block" "images" {
  bucket = aws_s3_bucket.images.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CORS: necesario para que el browser pueda hacer PUT directo a S3
resource "aws_s3_bucket_cors_configuration" "images" {
  bucket = aws_s3_bucket.images.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET", "HEAD"]
    allowed_origins = ["*"] # En prod: reemplazar con el dominio de CloudFront
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# Ciclo de vida: eliminar archivos huérfanos después de 90 días (optimización de costo)
resource "aws_s3_bucket_lifecycle_configuration" "images" {
  bucket = aws_s3_bucket.images.id

  rule {
    id     = "expire-incomplete-uploads"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}

# Política: permite solo a CloudFront (OAC) leer las fotos de usuarios
resource "aws_s3_bucket_policy" "images" {
  bucket = aws_s3_bucket.images.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontOAC"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.images.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.main.arn
          }
        }
      }
    ]
  })

  depends_on = [aws_cloudfront_distribution.main]
}
