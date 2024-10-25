# 6. Crear el recurso principal de la API ("/") en API Gateway
resource "aws_api_gateway_resource" "users" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "users" # Ruta base para los users
}

resource "aws_api_gateway_resource" "user_by_name" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.users.id
  path_part   = "{name}"
}

resource "aws_api_gateway_method" "get_user_by_name_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.user_by_name.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.name" = true # Indica que el parámetro "name" en la ruta es requerido
  }
}

resource "aws_api_gateway_integration" "get_user_by_name_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.user_by_name.id
  http_method = aws_api_gateway_method.get_user_by_name_method.http_method

  integration_http_method = "GET"
  uri                     = "http://${var.nlb_dns}/users/{name}" # Dirección de ECS con Fargate

  type            = "HTTP_PROXY"
  connection_type = "VPC_LINK"
  connection_id   = aws_api_gateway_vpc_link.my_vpc_link.id # Asegúrate de tener el VPC Link configurado

  request_parameters = {
    "integration.request.path.name" = "method.request.path.name"
  }
}

# 7. Configurar el método POST en el recurso "/users" para crear users que no requiere autenticación
resource "aws_api_gateway_method" "create_user_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.users.id
  http_method   = "POST"
  authorization = "NONE"
}

# 12. Crear la integración de API Gateway con ECS/Fargate para el método POST
resource "aws_api_gateway_integration" "create_user_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.users.id
  http_method = aws_api_gateway_method.create_user_method.http_method

  integration_http_method = "POST"
  uri                     = "http://${var.nlb_dns}/users" # Dirección de ECS con Fargate

  type            = "HTTP_PROXY"
  connection_type = "VPC_LINK"
  connection_id   = aws_api_gateway_vpc_link.my_vpc_link.id # Asegúrate de tener el VPC Link configurado
}

# 8. Configurar el método GET en el recurso "/users" requiere autenticación
resource "aws_api_gateway_method" "get_users_method" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.users.id
  http_method = "GET"

  authorization = "COGNITO_USER_POOLS" # Usamos Cognito para autenticar este endpoint

  #Requiere autenticación, vinculamos el Authorizer de Cognito aquí
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id

  request_parameters = {
    "method.request.header.Authorization" = true # Indicamos que se espera el token en la cabecera
  }
}

# 13. Crear la integración de API Gateway con ECS/Fargate para el método GET
resource "aws_api_gateway_integration" "get_users_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.users.id
  http_method = aws_api_gateway_method.get_users_method.http_method

  integration_http_method = "GET"
  uri                     = "http://${var.nlb_dns}/users"

  type            = "HTTP_PROXY"
  connection_type = "VPC_LINK"
  connection_id   = aws_api_gateway_vpc_link.my_vpc_link.id # Asegúrate de tener el VPC Link configurado
}
# resource "aws_api_gateway_integration" "create_user_integration" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   resource_id = aws_api_gateway_resource.users.id
#   http_method = aws_api_gateway_method.create_user_method.http_method
#   type        = "HTTP_PROXY"

#   integration_http_method = "POST"
#   uri                     = "http://${var.nlb_dns}/users" # Dirección de ECS con Fargate

# }

# # 13. Crear la integración de API Gateway con ECS/Fargate para el método GET
# resource "aws_api_gateway_integration" "get_users_integration" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   resource_id = aws_api_gateway_resource.users.id
#   http_method = aws_api_gateway_method.get_users_method.http_method
#   type        = "HTTP_PROXY"

#   integration_http_method = "GET"
#   uri                     = "http://${var.nlb_dns}/users"

# }
