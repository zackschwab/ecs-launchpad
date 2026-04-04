variable "project_name" {
  description = "Project name used as a prefix for all resource names and tags"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC to create the ALB in"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC, used to scope ALB egress to ECS tasks"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets to place the ALB in"
  type        = list(string)
}

variable "domain_name" {
  description = "Root domain name of the Route53 hosted zone (e.g. zackschwab.dev)"
  type        = string
}

variable "subdomain" {
  description = "Full subdomain to point at the ALB (e.g. api.zackschwab.dev)"
  type        = string
}

variable "app_port" {
  description = "Port the application container listens on"
  type        = number
  default     = 8000
}

variable "deregistration_delay" {
  description = "Seconds to wait before deregistering a target, reduces deployment time"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Additional tags to merge onto all resources"
  type        = map(string)
  default     = {}
}
