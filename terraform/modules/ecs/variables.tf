variable "project_name" {
  description = "Project name used as a prefix for all resource names and tags"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region, used to configure the CloudWatch log driver"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC to create the ECS security group in"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC, used to scope ECS task egress to VPC endpoints"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets to run ECS tasks in"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID of the ALB, used to scope ECS task ingress"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the ALB target group to register tasks with"
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of the ECS task execution role"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the ECS task role"
  type        = string
}

variable "container_image" {
  description = "Full ECR image URI to run in the task (e.g. 123456789.dkr.ecr.us-east-1.amazonaws.com/app:v1.0.0)"
  type        = string
}

variable "app_port" {
  description = "Port the application container listens on"
  type        = number
  default     = 8000
}

variable "task_cpu" {
  description = "CPU units for the Fargate task (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Memory in MB for the Fargate task (must be a valid combination with task_cpu)"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Number of ECS tasks to run"
  type        = number
  default     = 1
}

variable "log_retention_days" {
  description = "Number of days to retain ECS container logs in CloudWatch"
  type        = number
  default     = 30
}

variable "secrets" {
  description = "Map of environment variable names to Secrets Manager ARNs to inject into the container"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Additional tags to merge onto all resources"
  type        = map(string)
  default     = {}
}