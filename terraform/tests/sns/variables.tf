variable "email_subscriptions" {
  description = "List of email addresses to subscribe to the test SNS topic"
  type        = list(string)
  default     = []
}

variable "sms_subscriptions" {
  description = "List of phone numbers to subscribe to the test SNS topic (E.164 format, e.g. +12025551234)"
  type        = list(string)
  default     = []
}
