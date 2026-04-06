provider "aws" {
  region = "us-east-1"
}

module "ecr" {
  source       = "../../modules/ecr"
  project_name = "ecs-launchpad"
  environment  = "test"
}

output "repository_url" {
  value = module.ecr.repository_url
}

output "repository_arn" {
  value = module.ecr.repository_arn
}