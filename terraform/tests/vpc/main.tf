provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source       = "../../modules/vpc"
  project_name = "ecs-launchpad"
  environment  = "test"
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "availability_zones" {
  value = module.vpc.availability_zones
}