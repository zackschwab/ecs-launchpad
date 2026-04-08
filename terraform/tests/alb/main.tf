provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source       = "../../modules/vpc"
  project_name = "ecs-launchpad"
  environment  = "test"
}

module "alb" {
  source       = "../../modules/alb"
  project_name = "ecs-launchpad"
  environment  = "test"

  vpc_id            = module.vpc.vpc_id
  vpc_cidr          = module.vpc.vpc_cidr_block
  public_subnet_ids = module.vpc.public_subnet_ids
  domain_name       = var.domain_name
  subdomain         = var.subdomain
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "target_group_arn" {
  value = module.alb.target_group_arn
}

output "alb_security_group_id" {
  value = module.alb.alb_security_group_id
}
