resource "aws_dynamodb_table" "user_table" {
  name         = "TnUsersDB"
  billing_mode = "PAY_PER_REQUEST" # Usa un modo de pago por demanda
  hash_key     = "userId"

  attribute {
    name = "userId"
    type = "S"
  }

  # Opcional: índice secundario para email si necesitas consultas rápidas por email
  # global_secondary_index {
  #   name            = "EmailIndex"
  #   hash_key        = "email"
  #   projection_type = "ALL"
  # }

  tags = {
    service = "users"
  }
}
