output "app_url" {
  description = "HTTPS URL of the deployed application"
  value       = "https://${var.subdomain}"
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = module.alb.alb_dns_name
}

output "ecr_repository_url" {
  description = "ECR repository URL, used to push images for deployment"
  value       = module.ecr.repository_url
}

output "ecr_repository_name" {
  description = "ECR repository name, set as ECR_REPOSITORY in repository variables"
  value       = module.ecr.repository_name
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.ecs.service_name
}

output "ecs_task_definition_family" {
  description = "ECS task definition family, set as ECS_TASK_DEFINITION in repository variables"
  value       = module.ecs.task_definition_family
}

output "container_name" {
  description = "Container name, set as CONTAINER_NAME in repository variables"
  value       = module.ecs.container_name
}

output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions IAM role, set as AWS_ROLE_ARN in repository variables"
  value       = module.github_actions.role_arn
}

output "log_group_name" {
  description = "CloudWatch log group for container logs"
  value       = module.ecs.log_group_name
}

output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = module.cloudwatch.dashboard_name
}
