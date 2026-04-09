# ============================================================
# dynamodb.tf — Tabla DynamoDB: Mariposas + GSIs
# ============================================================
# Tabla principal que almacena los avistamientos de usuarios.
# Diseño de clave: PK = id (UUID), SK = usuarioId
# GSIs para consultas frecuentes sin full scan.
# ============================================================

resource "aws_dynamodb_table" "mariposas" {
  name         = local.dynamodb_table_name
  billing_mode = var.dynamodb_billing_mode  # PAY_PER_REQUEST (ideal para labs)

  # ── Clave primaria ────────────────────────────────────────
  hash_key  = "id"        # Partition Key: UUID único del avistamiento
  range_key = "usuarioId" # Sort Key: permite consultar por usuario eficientemente

  # ── Atributos indexados (solo los usados en índices) ─────
  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "usuarioId"
    type = "S"
  }

  attribute {
    name = "ecorregion"
    type = "S"
  }

  attribute {
    name = "fechaSubida"
    type = "S"
  }

  # ── GSI 1: Filtrar por ecorregión (tab de la galería) ────
  # Uso: GET /mariposas?ecorregion=pampeana
  global_secondary_index {
    name            = "GSI-ecorregion"
    hash_key        = "ecorregion"
    range_key       = "fechaSubida"
    projection_type = "ALL"
  }

  # ── GSI 2: Avistamientos de un usuario específico ────────
  # Uso: GET /mariposas?usuarioId=xxx (perfil del usuario)
  global_secondary_index {
    name            = "GSI-usuario"
    hash_key        = "usuarioId"
    range_key       = "fechaSubida"
    projection_type = "ALL"
  }

  # TTL opcional (útil para expirar datos de prueba automáticamente)
  # ttl {
  #   attribute_name = "expiresAt"
  #   enabled        = true
  # }

  # Point-in-Time Recovery: desactivado en dev para reducir costos
  point_in_time_recovery {
    enabled = false # Activar en prod
  }

  tags = {
    Name = "${local.name_prefix}-mariposas-table"
    Role = "main-data-store"
  }
}
