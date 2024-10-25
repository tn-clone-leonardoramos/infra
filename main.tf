terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  shared_credentials_files = ["~/.aws/credentials"]
  region                   = "us-east-1"
}

module "network" {
  source             = "./modules/network"
  availability_zones = ["us-east-1a", "us-east-1b"]
}

# module "ecs_instances" {
#   source = "./modules/ecs_instances"

#   nlb_security_group_id = module.network.nlb_security_group_id
#   nlb_target_group_arn  = module.network.nlb_target_group_arn
#   private_subnets       = module.network.private_subnets
# }
module "auth_cognito" {
  source = "./modules/auth_cognito"
}

module "api_gateway" {
  source = "./modules/api_gateway"

  nlb_dns               = module.network.nlb_dns
  cognito_user_pool_arn = module.auth_cognito.cognito_user_pool_arn
  nlb_security_group_id = module.network.nlb_security_group_id
  private_subnets       = module.network.private_subnets
  nlb_arn               = module.network.nlb_arn
}

module "database" {
  source = "./modules/database"
}

module "microservices" {
  source = "./modules/microservices"

  nlb_security_group_id = module.network.nlb_security_group_id
  nlb_target_group_arn  = module.network.nlb_target_group_arn
  private_subnets       = module.network.private_subnets

  dynamo_db_user_table_name = module.database.dynamo_db_user_table_name
  dynamo_db_user_table_arn  = module.database.dynamo_db_user_table_arn
}


