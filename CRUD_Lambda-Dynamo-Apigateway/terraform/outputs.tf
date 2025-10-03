output "api_gateway_url" {
  description = "URL del API Gateway"
  value       = "https://${aws_api_gateway_rest_api.movies_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/dev/Movies"
}

output "api_gateway_endpoints" {
  description = "Endpoints del API Gateway"
  value = {
    create_movie = "POST https://${aws_api_gateway_rest_api.movies_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/dev/Movies (body request)"
    get_movie    = "GET https://${aws_api_gateway_rest_api.movies_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/dev/Movies/{title}"
    update_movie = "PUT https://${aws_api_gateway_rest_api.movies_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/dev/Movies (body request)"
    delete_movie = "DELETE https://${aws_api_gateway_rest_api.movies_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/dev/Movies (body request)"
  }
}

output "dynamodb_table_name" {
  description = "Nombre de la tabla DynamoDB"
  value       = aws_dynamodb_table.movies.name
}

output "lambda_functions" {
  description = "Nombres de las funciones Lambda"
  value = {
    create_movie = aws_lambda_function.create_movie.function_name
    get_movie    = aws_lambda_function.get_movie.function_name
    update_movie = aws_lambda_function.update_movie.function_name
    delete_movie = aws_lambda_function.delete_movie.function_name
  }
}