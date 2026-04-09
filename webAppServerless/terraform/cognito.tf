# ============================================================
# cognito.tf — Amazon Cognito: User Pool + App Client
# ============================================================
# Gestiona la autenticación de usuarios de la aplicación.
# El User Pool emite JWT (ID Token / Access Token) que son
# validados por el Cognito JWT Authorizer de API Gateway.
# ============================================================

# ── User Pool ──────────────────────────────────────────────

resource "aws_cognito_user_pool" "main" {
  name = "${local.name_prefix}-users"

  # Permitir login con email o username
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  # Política de contraseñas
  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = false
    temporary_password_validity_days = 7
  }

  # Verificación de email al registrarse
  verification_message_template {
    default_email_option  = "CONFIRM_WITH_CODE"
    email_subject         = "Código de verificación - Mariposas Bonaerenses"
    email_message         = "Tu código de verificación es: {####}"
  }

  # Atributos personalizados del usuario
  schema {
    name                = "nombre"
    attribute_data_type = "String"
    mutable             = true
    required            = false

    string_attribute_constraints {
      min_length = 1
      max_length = 100
    }
  }

  # Configuración de tokens
  user_pool_add_ons {
    advanced_security_mode = "OFF" # Activar en prod (costo adicional)
  }

  tags = {
    Name = "${local.name_prefix}-user-pool"
  }
}

# ── App Client ─────────────────────────────────────────────
# El cliente de la aplicación que usa el frontend para
# autenticarse. Sin client_secret para apps SPA (público).

resource "aws_cognito_user_pool_client" "frontend" {
  name         = "${local.name_prefix}-frontend-client"
  user_pool_id = aws_cognito_user_pool.main.id

  # SPA no usa client secret (flujo público)
  generate_secret = false

  # Flujos de autenticación permitidos
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",   # Login con email + password
    "ALLOW_REFRESH_TOKEN_AUTH",   # Refresh de tokens
    "ALLOW_USER_SRP_AUTH",        # Secure Remote Password (más seguro)
  ]

  # Validez de los tokens
  access_token_validity  = 1    # 1 hora
  id_token_validity      = 1    # 1 hora
  refresh_token_validity = 30   # 30 días

  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }

  # No prevenir user existence errors (para mensajes de error del login)
  prevent_user_existence_errors = "ENABLED"
}

# ── Grupo de usuarios (opcional) ───────────────────────────
# Separar usuarios estándar de administradores o curadores

resource "aws_cognito_user_group" "contributors" {
  name         = "contributors"
  user_pool_id = aws_cognito_user_pool.main.id
  description  = "Usuarios que pueden subir avistamientos de mariposas"
  precedence   = 10
}
