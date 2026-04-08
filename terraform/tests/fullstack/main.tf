# Deploy all modules together to validate wiring and functionality
# Destroy this environment to avoid incurring charges
provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source       = "../../modules/vpc"
  project_name = "ecs-launchpad"
  environment  = "test"
}

module "vpc_endpoints" {
  source       = "../../modules/vpc_endpoints"
  project_name = "ecs-launchpad"
  environment  = "test"

  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnet_ids
  public_route_table_id  = module.vpc.public_route_table_id
  private_route_table_id = module.vpc.private_route_table_id
  ecs_security_group_id  = module.ecs.ecs_security_group_id
}

module "alb" {
  source       = "../../modules/alb"
  project_name = "ecs-launchpad"
  environment  = "test"

  vpc_id            = module.vpc.vpc_id
  vpc_cidr          = module.vpc.vpc_cidr_block
  public_subnet_ids = module.vpc.public_subnet_ids
  domain_name       = var.domain_name
  subdomain         = var.subdomain
}

resource "aws_secretsmanager_secret" "app" {
  name                    = "ecs-launchpad/test/app"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id     = aws_secretsmanager_secret.app.id
  secret_string = jsonencode({ placeholder = "test" })
}

module "iam" {
  source       = "../../modules/iam"
  project_name = "ecs-launchpad"
  environment  = "test"

  secret_arns = [aws_secretsmanager_secret.app.arn]
}

module "ecs" {
  source       = "../../modules/ecs"
  project_name = "ecs-launchpad"
  environment  = "test"
  aws_region   = "us-east-1"

  vpc_id                = module.vpc.vpc_id
  vpc_cidr              = module.vpc.vpc_cidr_block
  private_subnet_ids    = module.vpc.private_subnet_ids
  alb_security_group_id = module.alb.alb_security_group_id
  target_group_arn      = module.alb.target_group_arn
  execution_role_arn    = module.iam.execution_role_arn
  task_role_arn         = module.iam.task_role_arn
  container_image       = var.container_image

  secrets = {
    APP_SECRET = aws_secretsmanager_secret.app.arn
  }
}

module "sns" {
  source       = "../../modules/sns"
  project_name = "ecs-launchpad"
  environment  = "test"

  email_subscriptions = var.email_subscriptions
}

module "cloudwatch" {
  source       = "../../modules/cloudwatch"
  project_name = "ecs-launchpad"
  environment  = "test"

  cluster_name            = module.ecs.cluster_name
  service_name            = module.ecs.service_name
  alb_arn_suffix          = module.alb.alb_arn_suffix
  target_group_arn_suffix = module.alb.target_group_arn_suffix
  sns_topic_arn           = module.sns.topic_arn
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "cluster_name" {
  value = module.ecs.cluster_name
}

output "log_group_name" {
  value = module.ecs.log_group_name
}

output "dashboard_name" {
  value = module.cloudwatch.dashboard_name
}

output "sns_topic_arn" {
  value = module.sns.topic_arn
}
