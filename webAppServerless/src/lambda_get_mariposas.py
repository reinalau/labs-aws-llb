"""
lambda_get_mariposas.py — GET /mariposas
========================================
Retorna todos los avistamientos de usuarios almacenados en DynamoDB.
Requiere token JWT válido de Cognito (validado por API Gateway Authorizer).

Parámetros de query opcionales:
  - ecorregion: filtrar por ecorregión (usa GSI-ecorregion)
  - limit: máximo de items a retornar (default: 50)
"""

import json
import os
import boto3
from boto3.dynamodb.conditions import Key

# Variables de entorno inyectadas por Terraform/CloudFormation
TABLE_NAME     = os.environ["DYNAMODB_TABLE"]
REGION         = os.environ["REGION"]
CLOUDFRONT_URL = os.environ.get("CLOUDFRONT_URL", "")

dynamodb = boto3.resource("dynamodb", region_name=REGION)
table    = dynamodb.Table(TABLE_NAME)


def build_response(status_code: int, body: dict) -> dict:
    """Respuesta estándar con headers CORS."""
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type":                "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers":"Content-Type,Authorization",
            "Access-Control-Allow-Methods":"GET,POST,DELETE,OPTIONS",
        },
        "body": json.dumps(body, ensure_ascii=False, default=str),
    }


def enrich_with_image_url(item: dict) -> dict:
    """
    Convierte el imagenKey guardado en DynamoDB en una URL accesible vía CloudFront.
    Ejemplo: 'uploads/user-123/abc.jpg' → 'https://xxx.cloudfront.net/uploads/user-123/abc.jpg'
    """
    if "imagenKey" in item and CLOUDFRONT_URL:
        item["imagenUrl"] = f"{CLOUDFRONT_URL}/{item['imagenKey']}"
    return item


def lambda_handler(event: dict, context) -> dict:
    """Entry point de Lambda."""
    try:
        query_params  = event.get("queryStringParameters") or {}
        ecorregion    = query_params.get("ecorregion")
        limit         = int(query_params.get("limit", 50))

        if ecorregion:
            # Consulta eficiente usando el GSI por ecorregión
            response = table.query(
                IndexName="GSI-ecorregion",
                KeyConditionExpression=Key("ecorregion").eq(ecorregion),
                ScanIndexForward=False,  # Ordenar desc por fechaSubida
                Limit=limit,
            )
        else:
            # Scan completo (aceptable en lab con pocos items)
            response = table.scan(Limit=limit)

        items = [enrich_with_image_url(item) for item in response.get("Items", [])]

        return build_response(200, {"mariposas": items, "count": len(items)})

    except Exception as e:
        print(f"ERROR en GetMariposas: {e}")
        return build_response(500, {"error": "Error interno al obtener los avistamientos"})
