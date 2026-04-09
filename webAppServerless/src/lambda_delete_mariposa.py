"""
lambda_delete_mariposa.py — DELETE /mariposas/{id}
====================================================
Elimina un avistamiento de DynamoDB y su imagen en S3.
IMPORTANTE: Solo el usuario propietario puede eliminar su avistamiento.
Esta verificación se hace comparando el 'sub' del JWT con el 'usuarioId'
almacenado en DynamoDB (autorización a nivel de aplicación).

Path parameter:
  {id}: UUID del avistamiento a eliminar
"""

import json
import os

import boto3
from boto3.dynamodb.conditions import Key
from botocore.exceptions import ClientError

TABLE_NAME    = os.environ["DYNAMODB_TABLE"]
IMAGES_BUCKET = os.environ["S3_IMAGES_BUCKET"]
REGION        = os.environ["REGION"]

dynamodb  = boto3.resource("dynamodb", region_name=REGION)
table     = dynamodb.Table(TABLE_NAME)
s3_client = boto3.client("s3", region_name=REGION)


def build_response(status_code: int, body: dict) -> dict:
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


def get_usuario_id_from_jwt(event: dict) -> str:
    """Extrae el sub (user ID) del JWT validado por Cognito."""
    return (
        event.get("requestContext", {})
             .get("authorizer", {})
             .get("claims", {})
             .get("sub", "")
    )


def lambda_handler(event: dict, context) -> dict:
    try:
        # Obtener el ID del path parameter
        mariposa_id = (event.get("pathParameters") or {}).get("id")
        if not mariposa_id:
            return build_response(400, {"error": "Se requiere el parámetro {id}"})

        # Obtener usuario del JWT
        usuario_id = get_usuario_id_from_jwt(event)
        if not usuario_id:
            return build_response(401, {"error": "No se pudo identificar al usuario"})

        # Buscar el item en DynamoDB
        # Necesitamos el usuarioId (range key) para hacer el DeleteItem eficientemente.
        # Primero hacemos un Query por id para obtener el usuarioId.
        response = table.query(
            KeyConditionExpression=Key("id").eq(mariposa_id),
            Limit=1,
        )

        items = response.get("Items", [])
        if not items:
            return build_response(404, {"error": "Avistamiento no encontrado"})

        item = items[0]

        # Verificar que el usuario es el propietario
        if item.get("usuarioId") != usuario_id:
            return build_response(403, {
                "error": "No tenés permisos para eliminar este avistamiento"
            })

        # Eliminar de DynamoDB
        table.delete_item(
            Key={
                "id":        mariposa_id,
                "usuarioId": usuario_id,
            }
        )

        # Eliminar imagen de S3 (si existe el key)
        imagen_key = item.get("imagenKey")
        if imagen_key:
            try:
                s3_client.delete_object(Bucket=IMAGES_BUCKET, Key=imagen_key)
                print(f"Imagen eliminada de S3: {imagen_key}")
            except ClientError as e:
                # No fallar si la imagen ya no existe en S3
                print(f"WARN: No se pudo eliminar la imagen {imagen_key}: {e}")

        print(f"Avistamiento eliminado: id={mariposa_id}, usuario={usuario_id}")

        return build_response(200, {
            "message":    "Avistamiento eliminado exitosamente",
            "mariposaId": mariposa_id,
        })

    except ClientError as e:
        print(f"ERROR DynamoDB en DeleteMariposa: {e}")
        return build_response(500, {"error": "Error al eliminar de la base de datos"})

    except Exception as e:
        print(f"ERROR en DeleteMariposa: {e}")
        return build_response(500, {"error": "Error interno al eliminar el avistamiento"})
