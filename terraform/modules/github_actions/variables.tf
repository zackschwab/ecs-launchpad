variable "project_name" {
  description = "Project name used as a prefix for all resource names and tags"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository in owner/repo format (e.g. zackschwab/ecs-launchpad). Used to scope the OIDC trust policy."
  type        = string
}

variable "ecr_repository_arn" {
  description = "ARN of the ECR repository. Used to scope image push permissions."
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster. Used to scope ECS deploy permissions."
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS service. Used to scope ECS deploy permissions."
  type        = string
}

variable "ecs_execution_role_arn" {
  description = "ARN of the ECS task execution role. Required for iam:PassRole when registering new task definitions."
  type        = string
}

variable "tags" {
  description = "Additional tags to merge onto all resources"
  type        = map(string)
  default     = {}
}
