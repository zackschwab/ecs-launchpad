provider "aws" {
  region = "us-east-1"
}

# Placeholder secret so the IAM module has a real ARN to scope its policies to.
# In production this will be created outside Terraform or by a secrets module.
resource "aws_secretsmanager_secret" "placeholder" {
  name = "ecs-launchpad/test/placeholder"

  # Forces immediate deletion to prevent terraform destroy from failing
  # We would also have to wait 7 days by default to reuse this secret name
  recovery_window_in_days = 0
}

module "iam" {
  source       = "../../modules/iam"
  project_name = "ecs-launchpad"
  environment  = "test"

  secret_arns = [aws_secretsmanager_secret.placeholder.arn]
}

output "execution_role_arn" {
  value = module.iam.execution_role_arn
}

output "task_role_arn" {
  value = module.iam.task_role_arn
}
