variable "container_image" {
  description = "Full ECR image URI to deploy. Provide via terraform.tfvars — see terraform.tfvars.example"
  type        = string
}

variable "email_subscriptions" {
  description = "List of email addresses to subscribe to critical alerts"
  type        = list(string)
  default     = []
}
