terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# DynamoDB Table
resource "aws_dynamodb_table" "movies" {
  name           = "movies"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "title"

  attribute {
    name = "title"
    type = "S"
  }

  tags = {
    Name = "movies-table"
  }
}

# IAM Role for Lambda functions
resource "aws_iam_role" "lambda_role" {
  name = "lambda-movies-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Lambda to access DynamoDB
resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name = "lambda-dynamodb-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ]
        Resource = aws_dynamodb_table.movies.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

# Lambda Functions
data "archive_file" "lambda_create_zip" {
  type        = "zip"
  source_file = "${var.lambda_source_path}/lambda_function_create.py"
  output_path = "${var.lambda_source_path}/lambda_function_create.zip"
}

data "archive_file" "lambda_get_zip" {
  type        = "zip"
  source_file = "${var.lambda_source_path}/lambda_function_get.py"
  output_path = "${var.lambda_source_path}/lambda_function_get.zip"
}

data "archive_file" "lambda_update_zip" {
  type        = "zip"
  source_file = "${var.lambda_source_path}/lambda_function_update.py"
  output_path = "${var.lambda_source_path}/lambda_function_update.zip"
}

data "archive_file" "lambda_delete_zip" {
  type        = "zip"
  source_file = "${var.lambda_source_path}/lambda_function_delete.py"
  output_path = "${var.lambda_source_path}/lambda_function_delete.zip"
}

resource "aws_lambda_function" "create_movie" {
  filename        = "${var.lambda_source_path}/lambda_function_create.zip"
  function_name   = "create_movie"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function_create.lambda_handler"
  runtime         = "python3.11"
  source_code_hash = data.archive_file.lambda_create_zip.output_base64sha256

  depends_on = [aws_iam_role_policy_attachment.lambda_policy_attachment]
}

resource "aws_lambda_function" "get_movie" {
  filename         = "${var.lambda_source_path}/lambda_function_get.zip"
  function_name    = "get_movie"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function_get.lambda_handler"
  runtime         = "python3.9"
  source_code_hash = data.archive_file.lambda_get_zip.output_base64sha256

  depends_on = [aws_iam_role_policy_attachment.lambda_policy_attachment]
}

resource "aws_lambda_function" "update_movie" {
  filename         = "${var.lambda_source_path}/lambda_function_update.zip"
  function_name    = "update_movie"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function_update.lambda_handler"
  runtime         = "python3.9"
  source_code_hash = data.archive_file.lambda_update_zip.output_base64sha256

  depends_on = [aws_iam_role_policy_attachment.lambda_policy_attachment]
}

resource "aws_lambda_function" "delete_movie" {
  filename         = "${var.lambda_source_path}/lambda_function_delete.zip"
  function_name    = "delete_movie"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function_delete.lambda_handler"
  runtime         = "python3.9"
  source_code_hash = data.archive_file.lambda_delete_zip.output_base64sha256

  depends_on = [aws_iam_role_policy_attachment.lambda_policy_attachment]
}

# API Gateway
resource "aws_api_gateway_rest_api" "movies_api" {
  name        = "Movies API"
  description = "Movies API that connects a web endpoint to several Lambda functions"
}

# /Movies resource
resource "aws_api_gateway_resource" "movies_resource" {
  rest_api_id = aws_api_gateway_rest_api.movies_api.id
  parent_id   = aws_api_gateway_rest_api.movies_api.root_resource_id
  path_part   = "Movies"
}

# /Movies/{title} resource
resource "aws_api_gateway_resource" "title_resource" {
  rest_api_id = aws_api_gateway_rest_api.movies_api.id
  parent_id   = aws_api_gateway_resource.movies_resource.id
  path_part   = "{title}"
}

# POST method on /Movies for creating movies
resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.movies_api.id
  resource_id   = aws_api_gateway_resource.movies_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_integration" {
  rest_api_id = aws_api_gateway_rest_api.movies_api.id
  resource_id = aws_api_gateway_resource.movies_resource.id
  http_method = aws_api_gateway_method.post_method.http_method

  integration_http_method = "POST"
  type                   = "AWS"
  uri                    = aws_lambda_function.create_movie.invoke_arn

  passthrough_behavior = "WHEN_NO_MATCH"
  
}

resource "aws_api_gateway_method_response" "post_200" {
  rest_api_id = aws_api_gateway_rest_api.movies_api.id
  resource_id = aws_api_gateway_resource.movies_resource.id
  http_method = aws_api_gateway_method.post_method.http_method
  status_code = "200"

  # Response headers 
  response_parameters = {}
  
  # Response body con content-type application/json y model Empty
  response_models = {
    "application/json" = "Empty"
  }

}

# Integration Response (con template vacío como viste antes)
resource "aws_api_gateway_integration_response" "post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.movies_api.id
  resource_id = aws_api_gateway_resource.movies_resource.id
  http_method = aws_api_gateway_method.post_method.http_method
  status_code = "200"
  
  # Template vacío para application/json
  response_templates = {
    "application/json" = ""
  }
  
  depends_on = [aws_api_gateway_integration.post_integration]
}

# PUT method on /Movies for updating movies
resource "aws_api_gateway_method" "put_method" {
  rest_api_id   = aws_api_gateway_rest_api.movies_api.id
  resource_id   = aws_api_gateway_resource.movies_resource.id
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "put_integration" {
  rest_api_id = aws_api_gateway_rest_api.movies_api.id
  resource_id = aws_api_gateway_resource.movies_resource.id
  http_method = aws_api_gateway_method.put_method.http_method

  integration_http_method = "POST"
  type                   = "AWS"
  uri                    = aws_lambda_function.update_movie.invoke_arn

  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_method_response" "put_200" {
  rest_api_id = aws_api_gateway_rest_api.movies_api.id
  resource_id = aws_api_gateway_resource.movies_resource.id
  http_method = aws_api_gateway_method.put_method.http_method
  status_code = "200"

  # Response headers 
  response_parameters = {}
  
  # Response body con content-type application/json y model Empty
  response_models = {
    "application/json" = "Empty"
  }

}

# Integration Response (con template vacío como viste antes)
resource "aws_api_gateway_integration_response" "put_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.movies_api.id
  resource_id = aws_api_gateway_resource.movies_resource.id
  http_method = aws_api_gateway_method.put_method.http_method
  status_code = "200"
  
  # Template vacío para application/json
  response_templates = {
    "application/json" = ""
  }
  
  depends_on = [aws_api_gateway_integration.put_integration]
}



# GET method on /Movies/{title} for retrieving movies
resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = aws_api_gateway_rest_api.movies_api.id
  resource_id   = aws_api_gateway_resource.title_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_integration" {
  rest_api_id = aws_api_gateway_rest_api.movies_api.id
  resource_id = aws_api_gateway_resource.title_resource.id
  http_method = aws_api_gateway_method.get_method.http_method

  integration_http_method = "POST"
  type                   = "AWS"
  uri                    = aws_lambda_function.get_movie.invoke_arn

  request_templates = {
    "application/json" = <<EOF
{
    "title": "$input.params('title')"
}
EOF
  }
}

resource "aws_api_gateway_method_response" "get_method_response" {
  rest_api_id = aws_api_gateway_rest_api.movies_api.id
  resource_id = aws_api_gateway_resource.title_resource.id
  http_method = aws_api_gateway_method.get_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.movies_api.id
  resource_id = aws_api_gateway_resource.title_resource.id
  http_method = aws_api_gateway_method.get_method.http_method
  status_code = aws_api_gateway_method_response.get_method_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [aws_api_gateway_integration.get_integration]
}


# DELETE method on /Movies for deleting movies
resource "aws_api_gateway_method" "delete_method" {
  rest_api_id   = aws_api_gateway_rest_api.movies_api.id
  resource_id   = aws_api_gateway_resource.movies_resource.id
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "delete_integration" {
  rest_api_id = aws_api_gateway_rest_api.movies_api.id
  resource_id = aws_api_gateway_resource.movies_resource.id
  http_method = aws_api_gateway_method.delete_method.http_method

  integration_http_method = "POST"
  type                   = "AWS"
  uri                    = aws_lambda_function.delete_movie.invoke_arn

  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_method_response" "delete_200" {
  rest_api_id = aws_api_gateway_rest_api.movies_api.id
  resource_id = aws_api_gateway_resource.movies_resource.id
  http_method = aws_api_gateway_method.delete_method.http_method
  status_code = "200"

  # Response headers 
  response_parameters = {}
  
  # Response body con content-type application/json y model Empty
  response_models = {
    "application/json" = "Empty"
  }

}

# Integration Response (con template vacío como viste antes)
resource "aws_api_gateway_integration_response" "delete_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.movies_api.id
  resource_id = aws_api_gateway_resource.movies_resource.id
  http_method = aws_api_gateway_method.delete_method.http_method
  status_code = "200"
  
  # Template vacío para application/json
  response_templates = {
    "application/json" = ""
  }
  
  depends_on = [aws_api_gateway_integration.delete_integration]
}


# OPTIONS method for CORS on /Movies
resource "aws_api_gateway_method" "options_movies" {
  rest_api_id   = aws_api_gateway_rest_api.movies_api.id
  resource_id   = aws_api_gateway_resource.movies_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_movies_integration" {
  rest_api_id = aws_api_gateway_rest_api.movies_api.id
  resource_id = aws_api_gateway_resource.movies_resource.id
  http_method = aws_api_gateway_method.options_movies.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_movies_response" {
  rest_api_id = aws_api_gateway_rest_api.movies_api.id
  resource_id = aws_api_gateway_resource.movies_resource.id
  http_method = aws_api_gateway_method.options_movies.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  # Response body con content-type application/json y model Empty
  response_models = {
    "application/json" = "Empty"
  }
}


resource "aws_api_gateway_integration_response" "options_movies_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.movies_api.id
  resource_id = aws_api_gateway_resource.movies_resource.id
  http_method = aws_api_gateway_method.options_movies.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "''DELETE,GET,OPTIONS,POST,PUT''"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [aws_api_gateway_integration.options_movies_integration]
  
}

# Lambda permissions for API Gateway
resource "aws_lambda_permission" "create_movie_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_movie.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.movies_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "get_movie_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_movie.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.movies_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "update_movie_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_movie.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.movies_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "delete_movie_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_movie.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.movies_api.execution_arn}/*/*"
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "movies_deployment" {
  depends_on = [
    aws_api_gateway_integration.post_integration,
    aws_api_gateway_integration.get_integration,
    aws_api_gateway_integration.put_integration,
    aws_api_gateway_integration.delete_integration,
    aws_api_gateway_integration.options_movies_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.movies_api.id
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "movies_stage" {
  deployment_id = aws_api_gateway_deployment.movies_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.movies_api.id
  stage_name    = "dev"
  
  # Configuraciones adicionales del stage
  variables = {
    environment = "development"
  }
}

