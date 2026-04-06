variable "project_name" {
  description = "Project name used as a prefix for all resource names and tags"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
}

variable "secret_arns" {
  description = "List of Secrets Manager secret ARNs the execution and task roles are permitted to access"
  type        = list(string)

  validation {
    condition     = length(var.secret_arns) > 0
    error_message = "At least one secret ARN must be provided"
  }
}

variable "tags" {
  description = "Additional tags to merge onto all resources"
  type        = map(string)
  default     = {}
}
