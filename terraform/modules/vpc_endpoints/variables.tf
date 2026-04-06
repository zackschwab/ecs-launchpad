variable "project_name" {
  description = "Name of the project, used as a prefix for all resource names"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
}

variable "tags" {
  description = "Additional tags to merge into all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "ID of the VPC in which to create the endpoints"
  type        = string
}

variable "ecs_security_group_id" {
  description = "ID of the ECS task security group, granted HTTPS ingress to the endpoint SG"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs to attach to all Interface endpoints"
  type        = list(string)
}

variable "public_route_table_id" {
  description = "ID of the public route table to associate with the S3 Gateway endpoint"
  type        = string
}

variable "private_route_table_id" {
  description = "ID of the private route table to associate with the S3 Gateway endpoint"
  type        = string
}
