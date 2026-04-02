provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source       = "../../modules/vpc"
  project_name = "ecs-launchpad"
  environment  = "test"
}

# Placeholder for the ECS security group, since the ECS module isn't finished yet
# Will later be replaced by module.ecs.ecs_security_group_id
resource "aws_security_group" "ecs_placeholder" {
  name        = "ecs-launchpad-test-ecs-sg-placeholder"
  description = "Placeholder ECS SG for vpc_endpoints module testing"
  vpc_id      = module.vpc.vpc_id
}

module "vpc_endpoints" {
  source       = "../../modules/vpc_endpoints"
  project_name = "ecs-launchpad"
  environment  = "test"

  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnet_ids
  public_route_table_id  = module.vpc.public_route_table_id
  private_route_table_id = module.vpc.private_route_table_id
  ecs_security_group_id  = aws_security_group.ecs_placeholder.id
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_endpoint_security_group_id" {
  value = module.vpc_endpoints.vpc_endpoint_security_group_id
}
