provider "aws" {
  region = "us-east-1"
}

module "cloudwatch" {
  source       = "../../modules/cloudwatch"
  project_name = "ecs-launchpad"
  environment  = "test"

  cluster_name            = "ecs-launchpad-test"
  service_name            = "ecs-launchpad-test"
  alb_arn_suffix          = "app/ecs-launchpad-test-alb/test"
  target_group_arn_suffix = "targetgroup/ecs-launchpad-test-tg/test"
}
