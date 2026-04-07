variable "project_name" {
  description = "Project name used as a prefix for all resource names and tags"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
}

variable "email_subscriptions" {
  description = "List of email addresses to subscribe to critical alerts"
  type        = list(string)
  default     = []
}

variable "sms_subscriptions" {
  description = "List of phone numbers to subscribe to critical alerts (E.164 format, e.g. +12025551234)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags to merge onto all resources"
  type        = map(string)
  default     = {}
}
