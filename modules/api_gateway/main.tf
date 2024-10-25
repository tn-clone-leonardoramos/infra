# 4. Crear la API Gateway que se utilizará para la comunicación REST
resource "aws_api_gateway_rest_api" "api" {
  name        = "TN_API"
  description = "API para TN con autenticación utilizando Cognito"
}

# 5. Crear un recurso Cognito Authorizer en API Gateway: es el componente que vincula Cognito con API Gateway para la autenticación.
resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  name            = "CognitoAuthorizer"
  rest_api_id     = aws_api_gateway_rest_api.api.id
  type            = "COGNITO_USER_POOLS"
  identity_source = "method.request.header.Authorization" # Esperamos el token en el header "Authorization"

  # ID del Cognito User Pool que será usado para autenticar a los usuarios
  provider_arns = [var.cognito_user_pool_arn]
}

resource "aws_api_gateway_vpc_link" "my_vpc_link" {
  name = "my-vpc-link"
  # subnet_ids = var.private_subnets  # Subredes privadas donde está el nlb
  # security_group_ids = [var.nlb_security_group_id]           # Security group para permitir el tráfico

  target_arns = [var.nlb_arn]
}

# 14. Crear la implementación de la API para desplegarla
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [aws_api_gateway_method.create_user_method, aws_api_gateway_method.get_users_method, aws_api_gateway_method.get_user_by_name_method]

  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_stage" "dev" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "dev"
  deployment_id = aws_api_gateway_deployment.deployment.id

  # Habilitar logging y métricas
  # xray_tracing_enabled     = true
}
