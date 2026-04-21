# ecs-launchpad production root module
# Deploys the full stack: networking, compute, observability, and CI/CD IAM

module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
  environment  = var.environment
}

module "vpc_endpoints" {
  source       = "./modules/vpc_endpoints"
  project_name = var.project_name
  environment  = var.environment

  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnet_ids
  public_route_table_id  = module.vpc.public_route_table_id
  private_route_table_id = module.vpc.private_route_table_id
  ecs_security_group_id  = module.ecs.ecs_security_group_id
}

module "ecr" {
  source       = "./modules/ecr"
  project_name = var.project_name
  environment  = var.environment
}

# Placeholder secret, replace with real application secrets
resource "aws_secretsmanager_secret" "app" {
  name                    = "${var.project_name}/${var.environment}/app"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id     = aws_secretsmanager_secret.app.id
  secret_string = jsonencode({ placeholder = "replace-with-real-secret" })
}

module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
  environment  = var.environment

  secret_arns = [aws_secretsmanager_secret.app.arn]
}

module "alb" {
  source       = "./modules/alb"
  project_name = var.project_name
  environment  = var.environment

  vpc_id            = module.vpc.vpc_id
  vpc_cidr          = module.vpc.vpc_cidr_block
  public_subnet_ids = module.vpc.public_subnet_ids
  domain_name       = var.domain_name
  subdomain         = var.subdomain
}

module "ecs" {
  source       = "./modules/ecs"
  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  vpc_id                = module.vpc.vpc_id
  vpc_cidr              = module.vpc.vpc_cidr_block
  private_subnet_ids    = module.vpc.private_subnet_ids
  alb_security_group_id = module.alb.alb_security_group_id
  target_group_arn      = module.alb.target_group_arn
  execution_role_arn    = module.iam.execution_role_arn
  task_role_arn         = module.iam.task_role_arn
  container_image       = var.container_image
  desired_count         = var.desired_count

  secrets = {
    APP_SECRET = aws_secretsmanager_secret.app.arn
  }
}

module "sns" {
  source       = "./modules/sns"
  project_name = var.project_name
  environment  = var.environment
}

module "cloudwatch" {
  source       = "./modules/cloudwatch"
  project_name = var.project_name
  environment  = var.environment

  cluster_name            = module.ecs.cluster_name
  service_name            = module.ecs.service_name
  alb_arn_suffix          = module.alb.alb_arn_suffix
  target_group_arn_suffix = module.alb.target_group_arn_suffix
  sns_topic_arn           = module.sns.topic_arn
}

module "github_actions" {
  source       = "./modules/github_actions"
  project_name = var.project_name
  environment  = var.environment

  github_repository      = var.github_repository
  ecr_repository_arn     = module.ecr.repository_arn
  ecs_cluster_name       = module.ecs.cluster_name
  ecs_service_name       = module.ecs.service_name
  ecs_execution_role_arn = module.iam.execution_role_arn
}
