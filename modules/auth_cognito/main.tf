# 1. Crear un Cognito User Pool: este es el servicio que gestionará la autenticación de los usuarios.
resource "aws_cognito_user_pool" "user_pool" {
  name = "tn_app_user_pool"

  alias_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_uppercase = true
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
  }

  # Habilitar la auto-confirmación de cuentas para simplificar el flujo (cognito verifica el email)
  # auto_verified_attributes = ["email"]
}

# 2. Crear un App Client (sin secretos) para el User Pool: esta es la "aplicación" que se conectará al User Pool.
resource "aws_cognito_user_pool_client" "user_pool_client" {
  name         = "tn_user_pool_client"
  user_pool_id = aws_cognito_user_pool.user_pool.id

  # Permitir autenticación sin secreto del cliente para usarse en la app web
  generate_secret = false

  # Configuración del tiempo de vida de los tokens
  access_token_validity  = 24 # Tiempo de vida del token de acceso (horas)
  id_token_validity      = 24 # Tiempo de vida del token de identidad (horas)
  refresh_token_validity = 30 # Tiempo de vida del token de refresco (días)
}

