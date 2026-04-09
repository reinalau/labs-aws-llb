# ============================================================
# apigateway.tf — REST API + Cognito JWT Authorizer
# ============================================================
# Define la API REST con las 4 rutas de la aplicación.
# Todas las rutas requieren un JWT emitido por Cognito
# (validado automáticamente por el Cognito Authorizer).
#
# Rutas:
#   GET    /mariposas          → Lambda GetMariposas
#   POST   /mariposas          → Lambda CreateMariposa
#   DELETE /mariposas/{id}     → Lambda DeleteMariposa
#   POST   /mariposas/upload-url → Lambda GeneratePresignedUrl
# ============================================================

# ── REST API ───────────────────────────────────────────────

resource "aws_api_gateway_rest_api" "main" {
  name        = "${local.name_prefix}-api"
  description = "API REST para Mariposas Bonaerenses - avistamientos de usuarios"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Name = "${local.name_prefix}-api"
  }
}

# ── Cognito Authorizer ─────────────────────────────────────
# Valida el JWT de Cognito en el header Authorization de cada request

resource "aws_api_gateway_authorizer" "cognito" {
  name            = "cognito-authorizer"
  rest_api_id     = aws_api_gateway_rest_api.main.id
  type            = "COGNITO_USER_POOLS"
  identity_source = "method.request.header.Authorization"

  provider_arns = [aws_cognito_user_pool.main.arn]
}

# ── Recurso: /mariposas ────────────────────────────────────

resource "aws_api_gateway_resource" "mariposas" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "mariposas"
}

# ── Recurso: /mariposas/{id} ───────────────────────────────

resource "aws_api_gateway_resource" "mariposa_id" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.mariposas.id
  path_part   = "{id}"
}

# ── Recurso: /mariposas/upload-url ────────────────────────

resource "aws_api_gateway_resource" "upload_url" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.mariposas.id
  path_part   = "upload-url"
}

# ── Método: GET /mariposas ─────────────────────────────────

resource "aws_api_gateway_method" "get_mariposas" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.mariposas.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "get_mariposas" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.mariposas.id
  http_method             = aws_api_gateway_method.get_mariposas.http_method
  integration_http_method = "POST" # Lambda siempre usa POST internamente
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_mariposas.invoke_arn
}

# ── Método: POST /mariposas ────────────────────────────────

resource "aws_api_gateway_method" "create_mariposa" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.mariposas.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "create_mariposa" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.mariposas.id
  http_method             = aws_api_gateway_method.create_mariposa.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.create_mariposa.invoke_arn
}

# ── Método: DELETE /mariposas/{id} ────────────────────────

resource "aws_api_gateway_method" "delete_mariposa" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.mariposa_id.id
  http_method   = "DELETE"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "delete_mariposa" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.mariposa_id.id
  http_method             = aws_api_gateway_method.delete_mariposa.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.delete_mariposa.invoke_arn
}

# ── Método: POST /mariposas/upload-url ────────────────────

resource "aws_api_gateway_method" "presigned_url" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.upload_url.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "presigned_url" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.upload_url.id
  http_method             = aws_api_gateway_method.presigned_url.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.presigned_url.invoke_arn
}

# ── CORS: OPTIONS para cada recurso ───────────────────────
# Necesario para que el browser permita llamadas cross-origin

module "cors_mariposas" {
  source      = "./modules/cors"
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.mariposas.id
}

module "cors_mariposa_id" {
  source      = "./modules/cors"
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.mariposa_id.id
}

module "cors_upload_url" {
  source      = "./modules/cors"
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.upload_url.id
}

# ── Permisos: API Gateway puede invocar cada Lambda ───────

resource "aws_lambda_permission" "apigw_get" {
  statement_id  = "AllowAPIGatewayInvokeGet"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_mariposas.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_create" {
  statement_id  = "AllowAPIGatewayInvokeCreate"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_mariposa.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_delete" {
  statement_id  = "AllowAPIGatewayInvokeDelete"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_mariposa.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_presigned" {
  statement_id  = "AllowAPIGatewayInvokePresigned"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.presigned_url.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

# ── Deployment y Stage ─────────────────────────────────────

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  # Forzar re-deploy cuando cambia cualquier método o integración
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_method.get_mariposas.id,
      aws_api_gateway_method.create_mariposa.id,
      aws_api_gateway_method.delete_mariposa.id,
      aws_api_gateway_method.presigned_url.id,
      aws_api_gateway_integration.get_mariposas.id,
      aws_api_gateway_integration.create_mariposa.id,
      aws_api_gateway_integration.delete_mariposa.id,
      aws_api_gateway_integration.presigned_url.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.environment

  # Logging de API Gateway a CloudWatch
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format          = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      resourcePath   = "$context.resourcePath"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
    })
  }

  tags = {
    Name = "${local.name_prefix}-api-stage"
  }
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${local.name_prefix}"
  retention_in_days = 1
}
