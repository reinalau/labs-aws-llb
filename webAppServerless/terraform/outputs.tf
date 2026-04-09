# ============================================================
# outputs.tf — Salidas del stack
# ============================================================
# Valores importantes que se muestran al finalizar el apply.
# Estos valores se necesitan para:
#   - Configurar el frontend (URL API, User Pool, Client ID)
#   - Subir el build del frontend al bucket S3
#   - Hacer pruebas con curl/Postman
# ============================================================

output "cloudfront_url" {
  description = "URL pública del sitio web (CloudFront)"
  value       = "https://${aws_cloudfront_distribution.main.domain_name}"
}

output "api_gateway_url" {
  description = "URL base de la REST API (usar en el frontend como VITE_API_URL)"
  value       = aws_api_gateway_stage.main.invoke_url
}

output "cognito_user_pool_id" {
  description = "ID del Cognito User Pool (usar en el frontend como VITE_COGNITO_USER_POOL_ID)"
  value       = aws_cognito_user_pool.main.id
}

output "cognito_client_id" {
  description = "ID del App Client de Cognito (usar en el frontend como VITE_COGNITO_CLIENT_ID)"
  value       = aws_cognito_user_pool_client.frontend.id
}

output "frontend_bucket_name" {
  description = "Nombre del bucket S3 del frontend (para subir el build con aws s3 sync)"
  value       = aws_s3_bucket.frontend.id
}

output "images_bucket_name" {
  description = "Nombre del bucket S3 de imágenes de usuarios"
  value       = aws_s3_bucket.images.id
}

output "dynamodb_table_name" {
  description = "Nombre de la tabla DynamoDB"
  value       = aws_dynamodb_table.mariposas.name
}

output "deploy_frontend_command" {
  description = "Comando para subir el build del frontend al bucket S3"
  value       = "aws s3 sync frontend/app/dist/ s3://${aws_s3_bucket.frontend.id} --delete"
}

output "cloudfront_distribution_id" {
  description = "ID de la distribución de CloudFront (necesario para invalidar caché)"
  value       = aws_cloudfront_distribution.main.id
}

output "invalidate_cache_command" {
  description = "Comando para limpiar la caché de CloudFront cuando se actualiza el frontend"
  value       = "aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.main.id} --paths \"/*\""
}
