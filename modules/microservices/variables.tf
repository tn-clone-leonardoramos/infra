variable "private_subnets" {
  type = list(string)
}

variable "nlb_security_group_id" {
  type = string
}

variable "nlb_target_group_arn" {
  type = string
}

variable "dynamo_db_user_table_arn" {
  type = string
}

variable "dynamo_db_user_table_name" {
  type = string
}

