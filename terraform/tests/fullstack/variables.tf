variable "container_image" {
  description = "Full ECR image URI to deploy. Provide via terraform.tfvars — see terraform.tfvars.example"
  type        = string
}

variable "email_subscriptions" {
  description = "List of email addresses to subscribe to critical alerts"
  type        = list(string)
  default     = []
}

variable "domain_name" {
  description = "Root domain name of the Route53 hosted zone"
  type        = string
}

variable "subdomain" {
  description = "Full subdomain to point at the ALB"
  type        = string
}

variable "project_name" {
  description = "Project name used across all modules"
  type        = string
  default     = "ecs-launchpad"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "test"
}
variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}