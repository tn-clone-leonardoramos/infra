output "dynamo_db_user_table_arn" {
  value = aws_dynamodb_table.user_table.arn
}

output "dynamo_db_user_table_name" {
  value = aws_dynamodb_table.user_table.name
}
