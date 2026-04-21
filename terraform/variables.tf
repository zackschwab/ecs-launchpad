variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used as a prefix for all resource names and tags"
  type        = string
  default     = "ecs-launchpad"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "prod"
}

variable "domain_name" {
  description = "Root domain name of the Route53 hosted zone"
  type        = string
}

variable "subdomain" {
  description = "Full subdomain to point at the ALB"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository in owner/repo format, used to scope the OIDC trust policy"
  type        = string
}

variable "container_image" {
  description = "Full ECR image URI to deploy (e.g. 123456789.dkr.ecr.us-east-1.amazonaws.com/app:v1.0.0)"
  type        = string
}

variable "desired_count" {
  description = "Number of ECS tasks to run"
  type        = number
  default     = 1
}

variable "tags" {
  description = "Additional tags to merge onto all resources"
  type        = map(string)
  default     = {}
}
