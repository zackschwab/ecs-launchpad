variable "project_name" {
  description = "Name of the project, will be used as a prefix for all resource names"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod"
  }
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "module_name" {
  description = "Name of the terraform module, to tag resources for debugging and cost attributions"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
