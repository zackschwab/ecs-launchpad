variable "github_repository" {
  description = "GitHub repository in owner/repo format (e.g. zackschwab/ecs-launchpad)"
  type        = string
}

variable "ecr_repository_arn" {
  description = "ARN of the ECR repository to scope image push permissions"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster to scope deploy permissions"
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS service to scope deploy permissions"
  type        = string
}

variable "ecs_execution_role_arn" {
  description = "ARN of the ECS task execution role required for iam:PassRole"
  type        = string
}
