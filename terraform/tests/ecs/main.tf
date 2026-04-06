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
  domain_name       = "zackschwab.dev"
  subdomain         = "api.zackschwab.dev"
}

# Placeholder secret for the IAM module
resource "aws_secretsmanager_secret" "placeholder" {
  name                    = "ecs-launchpad/test/placeholder"
  recovery_window_in_days = 0
}

module "iam" {
  source       = "../../modules/iam"
  project_name = "ecs-launchpad"
  environment  = "test"

  secret_arns = [aws_secretsmanager_secret.placeholder.arn]
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
  container_image = var.container_image

  secrets = {
    PLACEHOLDER_SECRET = aws_secretsmanager_secret.placeholder.arn
  }
}

resource "aws_secretsmanager_secret_version" "placeholder" {
  secret_id     = aws_secretsmanager_secret.placeholder.id
  secret_string = jsonencode({ placeholder = "test" })
}

output "cluster_name" {
  value = module.ecs.cluster_name
}

output "service_name" {
  value = module.ecs.service_name
}

output "ecs_security_group_id" {
  value = module.ecs.ecs_security_group_id
}

output "log_group_name" {
  value = module.ecs.log_group_name
}
