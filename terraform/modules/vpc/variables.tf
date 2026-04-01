variable "project_name" {
  description = "Project name used as a prefix for all resource names and tags"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of AZs to deploy into"
  type        = number
  default     = 2
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets (one per AZ). Length must match az_count"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) == var.az_count
    error_message = "public_subnet_cidrs length (${length(var.public_subnet_cidrs)}) must equal az_count (${var.az_count})"
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets (one per AZ). Length must match az_count"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]

  validation {
    condition     = length(var.private_subnet_cidrs) == var.az_count
    error_message = "private_subnet_cidrs length (${length(var.private_subnet_cidrs)}) must equal az_count (${var.az_count})"
  }
}

variable "availability_zones" {
  description = "Explicit list of AZs to deploy into. Length must match az_count. Defaults to the first az_count AZs in the region"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.availability_zones) == 0 || length(var.availability_zones) == var.az_count
    error_message = "availability_zones length (${length(var.availability_zones)}) must equal az_count (${var.az_count}), or be empty to auto-select"
  }
}

variable "tags" {
  description = "Additional tags to merge onto all resources"
  type        = map(string)
  default     = {}
}