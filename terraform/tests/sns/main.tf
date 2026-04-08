provider "aws" {
  region = "us-east-1"
}

module "sns" {
  source       = "../../modules/sns"
  project_name = "ecs-launchpad"
  environment  = "test"

  email_subscriptions = var.email_subscriptions
  sms_subscriptions   = var.sms_subscriptions
}

output "topic_arn" {
  value = module.sns.topic_arn
}

output "topic_name" {
  value = module.sns.topic_name
}
