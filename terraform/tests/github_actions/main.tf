provider "aws" {
  region = "us-east-1"
}

module "github_actions" {
  source       = "../../modules/github_actions"
  project_name = "ecs-launchpad"
  environment  = "test"

  github_repository      = var.github_repository
  ecr_repository_arn     = var.ecr_repository_arn
  ecs_cluster_name       = var.ecs_cluster_name
  ecs_service_name       = var.ecs_service_name
  ecs_execution_role_arn = var.ecs_execution_role_arn
}

output "role_arn" {
  description = "Set this as AWS_ROLE_ARN in your GitHub repository variables"
  value       = module.github_actions.role_arn
}

output "oidc_provider_arn" {
  value = module.github_actions.oidc_provider_arn
}
