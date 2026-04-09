"""
lambda_generate_presigned_url.py — POST /mariposas/upload-url
==============================================================
Genera una S3 Presigned URL para que el frontend pueda subir
una imagen directamente al bucket S3, sin pasar por Lambda.

Por qué este patrón (Presigned URL):
  - Lambda tiene límite de 6MB en payload → las fotos lo superan
  - Evita costos de transferencia innecesarios via API Gateway
  - La subida es directa y más rápida (browser → S3)

Flujo completo:
  1. Frontend llama POST /mariposas/upload-url → obtiene {uploadUrl, imagenKey}
  2. Frontend hace PUT directamente a uploadUrl con la imagen
  3. Frontend llama POST /mariposas con el imagenKey y la metadata

Body esperado:
  {
    "fileExtension": "jpg",     // "jpg", "jpeg", "png", "webp"
    "contentType":   "image/jpeg"
  }

Respuesta:
  {
    "uploadUrl": "https://s3.amazonaws.com/bucket/uploads/user/uuid.jpg?...",
    "imagenKey": "uploads/user-123/uuid.jpg"
  }
"""

import json
import os
import uuid

import boto3
from botocore.exceptions import ClientError

IMAGES_BUCKET     = os.environ["S3_IMAGES_BUCKET"]
REGION            = os.environ["REGION"]
PRESIGNED_URL_TTL = int(os.environ.get("PRESIGNED_URL_TTL", 300))  # 5 minutos por defecto

s3_client = boto3.client("s3", region_name=REGION)

CONTENT_TYPES_PERMITIDOS = {
    "jpg":  "image/jpeg",
    "jpeg": "image/jpeg",
    "png":  "image/png",
    "webp": "image/webp",
}

# Tamaño máximo de imagen: 10MB (validación de Content-Length en la presigned URL)
MAX_IMAGE_SIZE_BYTES = 10 * 1024 * 1024


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
    return (
        event.get("requestContext", {})
             .get("authorizer", {})
             .get("claims", {})
             .get("sub", "")
    )


def lambda_handler(event: dict, context) -> dict:
    try:
        body = json.loads(event.get("body") or "{}")

        file_extension = body.get("fileExtension", "").lower().lstrip(".")
        content_type   = body.get("contentType", "")

        # Validar extensión/tipo de archivo
        if file_extension not in CONTENT_TYPES_PERMITIDOS:
            return build_response(400, {
                "error": f"Extensión no permitida. Usar: {list(CONTENT_TYPES_PERMITIDOS.keys())}"
            })

        expected_content_type = CONTENT_TYPES_PERMITIDOS[file_extension]
        if content_type and content_type != expected_content_type:
            return build_response(400, {
                "error": f"Content-Type '{content_type}' no coincide con la extensión '{file_extension}'"
            })

        # Obtener usuario del JWT
        usuario_id = get_usuario_id_from_jwt(event)
        if not usuario_id:
            return build_response(401, {"error": "No se pudo identificar al usuario"})

        # Construir el key S3: uploads/{usuarioId}/{uuid}.{ext}
        # El usuarioId en el path evita que un usuario escriba en carpetas ajenas
        imagen_id  = str(uuid.uuid4())
        imagen_key = f"uploads/{usuario_id}/{imagen_id}.{file_extension}"

        # Generar presigned URL para PUT
        # Las condiciones limitan el tamaño máximo de la imagen
        upload_url = s3_client.generate_presigned_url(
            "put_object",
            Params={
                "Bucket":      IMAGES_BUCKET,
                "Key":         imagen_key,
                "ContentType": expected_content_type,
            },
            ExpiresIn=PRESIGNED_URL_TTL,
        )

        print(f"Presigned URL generada: key={imagen_key}, usuario={usuario_id}, ttl={PRESIGNED_URL_TTL}s")

        return build_response(200, {
            "uploadUrl":  upload_url,
            "imagenKey":  imagen_key,
            "expiresIn":  PRESIGNED_URL_TTL,
            "maxSizeBytes": MAX_IMAGE_SIZE_BYTES,
        })

    except json.JSONDecodeError:
        return build_response(400, {"error": "Body inválido, se esperaba JSON"})

    except ClientError as e:
        print(f"ERROR S3 en GeneratePresignedUrl: {e}")
        return build_response(500, {"error": "Error al generar la URL de subida"})

    except Exception as e:
        print(f"ERROR en GeneratePresignedUrl: {e}")
        return build_response(500, {"error": "Error interno al generar la URL"})
