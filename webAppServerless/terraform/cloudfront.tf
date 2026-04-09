# ============================================================
# cloudfront.tf — CDN: CloudFront Distribution + OAC
# ============================================================
# CloudFront actúa como el front-door único de la aplicación:
#   - Sirve el frontend estático desde S3 (Origin 1)
#   - Sirve las imágenes de usuarios desde S3 (Origin 2)
# OAC (Origin Access Control) reemplaza al OAI deprecado.
# ============================================================

# ── Origin Access Control (seguridad S3 → CloudFront) ──────

resource "aws_cloudfront_origin_access_control" "frontend" {
  name                              = "${local.name_prefix}-frontend-oac"
  description                       = "OAC para el bucket S3 del frontend"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_origin_access_control" "images" {
  name                              = "${local.name_prefix}-images-oac"
  description                       = "OAC para el bucket S3 de imágenes"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ── Distribución Principal ──────────────────────────────────

resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = var.cloudfront_price_class
  comment             = "${local.name_prefix} - Mariposas Bonaerenses"

  # Origin 1: Frontend SPA (S3)
  origin {
    domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id                = "S3-frontend"
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id
  }

  # Origin 2: Imágenes de usuarios (S3)
  origin {
    domain_name              = aws_s3_bucket.images.bucket_regional_domain_name
    origin_id                = "S3-images"
    origin_access_control_id = aws_cloudfront_origin_access_control.images.id
  }

  # Comportamiento por defecto → Frontend SPA
  default_cache_behavior {
    target_origin_id       = "S3-frontend"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600   # 1 hora de caché para assets del frontend
    max_ttl     = 86400  # 24 horas máximo
  }

  # Comportamiento para /uploads/* → Imágenes de usuarios
  ordered_cache_behavior {
    path_pattern           = "/uploads/*"
    target_origin_id       = "S3-images"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 86400   # Las imágenes se cachean más tiempo
    max_ttl     = 604800  # 7 días
  }

  # SPA: redirigir 404/403 al index.html para que React Router maneje las rutas
  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true # En prod: usar ACM custom cert
  }

  tags = {
    Name = "${local.name_prefix}-distribution"
  }
}
