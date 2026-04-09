"""
lambda_create_mariposa.py — POST /mariposas
============================================
Persiste la metadata de un nuevo avistamiento en DynamoDB.
La imagen ya fue subida directamente a S3 por el frontend
usando la Presigned URL generada por lambda_generate_presigned_url.

Body esperado (JSON):
  {
    "nombreComun":      "Mariposa Bandera Argentina",
    "nombreCientifico": "Morpho epistrophus",
    "descripcion":      "Vista en el jardín...",
    "plantaNutricia":   { "nombreCientifico": "...", "nombreComun": "..." },
    "ecorregion":       "pampeana",
    "imagenKey":        "uploads/user-123/uuid.jpg"
  }
"""

import json
import os
import uuid
from datetime import datetime, timezone

import boto3
from botocore.exceptions import ClientError

TABLE_NAME = os.environ["DYNAMODB_TABLE"]
REGION     = os.environ["REGION"]

dynamodb = boto3.resource("dynamodb", region_name=REGION)
table    = dynamodb.Table(TABLE_NAME)

ECORREGIONES_VALIDAS = {"pampeana", "espinal", "delta"}

CAMPOS_REQUERIDOS = [
    "nombreComun",
    "nombreCientifico",
    "descripcion",
    "plantaNutricia",
    "ecorregion",
    "imagenKey",
]


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


def get_usuario_from_jwt(event: dict) -> dict:
    """
    Extrae los claims del JWT validado por Cognito Authorizer.
    API Gateway inyecta los claims en requestContext.authorizer.claims.
    """
    claims = (
        event.get("requestContext", {})
             .get("authorizer", {})
             .get("claims", {})
    )
    return {
        "usuarioId":     claims.get("sub", "unknown"),
        "usuarioEmail":  claims.get("email", "unknown"),
        "usuarioNombre": claims.get("nombre", claims.get("email", "unknown")),
    }


def lambda_handler(event: dict, context) -> dict:
    try:
        # Parsear body
        body = json.loads(event.get("body") or "{}")

        # Validar campos requeridos
        faltantes = [c for c in CAMPOS_REQUERIDOS if not body.get(c)]
        if faltantes:
            return build_response(400, {
                "error": f"Campos requeridos faltantes: {', '.join(faltantes)}"
            })

        # Validar ecorregión
        if body["ecorregion"] not in ECORREGIONES_VALIDAS:
            return build_response(400, {
                "error": f"Ecorregión inválida. Valores válidos: {ECORREGIONES_VALIDAS}"
            })

        # Obtener datos del usuario desde el JWT
        usuario = get_usuario_from_jwt(event)

        # Construir item DynamoDB
        item_id      = str(uuid.uuid4())
        fecha_subida = datetime.now(timezone.utc).isoformat()

        item = {
            "id":               item_id,
            "usuarioId":        usuario["usuarioId"],
            "usuarioEmail":     usuario["usuarioEmail"],
            "usuarioNombre":    usuario["usuarioNombre"],
            "nombreComun":      body["nombreComun"].strip(),
            "nombreCientifico": body["nombreCientifico"].strip(),
            "descripcion":      body["descripcion"].strip(),
            "plantaNutricia":   body["plantaNutricia"],
            "ecorregion":       body["ecorregion"],
            "imagenKey":        body["imagenKey"],
            "fechaSubida":      fecha_subida,
        }

        # Guardar en DynamoDB (condition: evitar sobreescribir si el id ya existe)
        table.put_item(
            Item=item,
            ConditionExpression="attribute_not_exists(id)",
        )

        print(f"Avistamiento creado: id={item_id}, usuario={usuario['usuarioId']}")

        return build_response(201, {
            "message":    "Avistamiento guardado exitosamente",
            "mariposaId": item_id,
            "fechaSubida": fecha_subida,
        })

    except ClientError as e:
        if e.response["Error"]["Code"] == "ConditionalCheckFailedException":
            return build_response(409, {"error": "El avistamiento ya existe"})
        print(f"ERROR DynamoDB en CreateMariposa: {e}")
        return build_response(500, {"error": "Error al guardar en la base de datos"})

    except json.JSONDecodeError:
        return build_response(400, {"error": "Body inválido, se esperaba JSON"})

    except Exception as e:
        print(f"ERROR en CreateMariposa: {e}")
        return build_response(500, {"error": "Error interno al crear el avistamiento"})
