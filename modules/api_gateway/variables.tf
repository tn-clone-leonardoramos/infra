variable "nlb_dns" {
  type = string
}

variable "nlb_arn" {
  type = string
}

variable "nlb_security_group_id" {
  type = string
}

variable "cognito_user_pool_arn" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

