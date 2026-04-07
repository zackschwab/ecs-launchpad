variable "project_name" {
  description = "Project name used as a prefix for all resource names and tags"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
}

variable "cluster_name" {
  description = "Name of the ECS cluster to monitor"
  type        = string
}

variable "service_name" {
  description = "Name of the ECS service to monitor"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ARN suffix of the ALB, used to scope CloudWatch ALB metrics"
  type        = string
}

variable "target_group_arn_suffix" {
  description = "ARN suffix of the ALB target group, used to scope CloudWatch target group metrics"
  type        = string
}

variable "cpu_threshold" {
  description = "CPU utilization percentage threshold to trigger the ECS CPU alarm"
  type        = number
  default     = 80
}

variable "memory_threshold" {
  description = "Memory utilization percentage threshold to trigger the ECS memory alarm"
  type        = number
  default     = 80
}

variable "error_5xx_threshold" {
  description = "Number of ALB 5xx errors per minute to trigger the error alarm"
  type        = number
  default     = 10
}

variable "tags" {
  description = "Additional tags to merge onto all resources"
  type        = map(string)
  default     = {}
}
