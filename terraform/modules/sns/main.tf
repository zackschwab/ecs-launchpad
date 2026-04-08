locals {
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags,
  )
}

# Central notification SNS topic for critical infrastructure alerts
resource "aws_sns_topic" "this" {
  name = "${var.project_name}-${var.environment}-alerts"

  tags = local.common_tags
}

# Subscriptions

# Email subscriptions
# Each address must confirm the subscription via the email AWS sends
resource "aws_sns_topic_subscription" "email" {
  for_each = toset(var.email_subscriptions)

  topic_arn = aws_sns_topic.this.arn
  protocol  = "email"
  endpoint  = each.value
}

# SMS subscriptions
# Subscribers receive alerts as text messages
resource "aws_sns_topic_subscription" "sms" {
  for_each = toset(var.sms_subscriptions)

  topic_arn = aws_sns_topic.this.arn
  protocol  = "sms"
  endpoint  = each.value
}
