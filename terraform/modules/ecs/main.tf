data "aws_region" "current" {}

# S3 Gateway endpoints route traffic to S3's public IP ranges via the route table.
# A prefix list is used to scope the egress rule to S3 IPs — AWS maintains this automatically.
data "aws_prefix_list" "s3" {
  name = "com.amazonaws.${data.aws_region.current.region}.s3"
}

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

# Security Group

# Security group for ECS Fargate tasks to only accept traffic from the ALB
resource "aws_security_group" "ecs" {
  name        = "${var.project_name}-${var.environment}-ecs-sg"
  description = "ECS tasks: allow inbound from ALB SG only"
  vpc_id      = var.vpc_id

  # Restrict ingress to the application port only
  ingress {
    description     = "Traffic from ALB"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  # Enable egress to Interface VPC endpoints (ECR, Secrets Manager, CloudWatch, ECS control plane)
  egress {
    description = "HTTPS to Interface VPC endpoints"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"

    # Scoped to the VPC CIDR — Interface endpoint ENIs live inside the VPC
    cidr_blocks = [var.vpc_cidr]
  }

  # S3 Gateway endpoints route via the route table to S3 public IPs, not through the VPC CIDR.
  # The prefix list represents all S3 IP ranges and is maintained automatically by AWS.
  egress {
    description     = "HTTPS to S3 Gateway endpoint for ECR image layer pulls"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = [data.aws_prefix_list.s3.id]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-ecs-sg"
  })
}


# Cluster

# ECS cluster for running Fargate tasks
resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}-${var.environment}"

  # Enable Container Insights for CPU and memory monitoring at the task and service level
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = local.common_tags
}

# Pin the cluster to Fargate, removing the need to manage EC2 instances
resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
  }
}

# CloudWatch Log Group

# Log group for ECS container logs
# Defined here rather than the CloudWatch module to avoid a circular dependency
# with the task definition, which needs the log group name at creation time
resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.project_name}-${var.environment}"
  retention_in_days = var.log_retention_days

  tags = local.common_tags
}

# Task Definition

# Defines the container configuration for the Fargate task
resource "aws_ecs_task_definition" "this" {
  family                   = "${var.project_name}-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.task_cpu
  memory                   = var.task_memory

  # The execution role is used by ECS to start the task
  execution_role_arn = var.execution_role_arn

  # The task role is used by the running container to call AWS services
  task_role_arn = var.task_role_arn

  container_definitions = jsonencode([
    {
      name  = var.project_name
      image = var.container_image

      portMappings = [
        {
          containerPort = var.app_port
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "ENVIRONMENT"
          value = var.environment
        },
        {
          name  = "APP_VERSION"
          value = "unknown"
        }
      ]

      # Inject secrets from Secrets Manager as environment variables
      # ECS fetches these before the container starts using the execution role
      secrets = [
        for name, arn in var.secrets : {
          name      = name
          valueFrom = arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }

      # Mark the container as essential so the task stops if it crashes
      essential = true
    }
  ])

  tags = local.common_tags
}

# Service

# ECS service to run and maintain the desired number of tasks
resource "aws_ecs_service" "this" {
  name            = "${var.project_name}-${var.environment}"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  # Register tasks with the ALB target group for health-based routing
  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.project_name
    container_port   = var.app_port
  }

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.ecs.id]

    # Tasks run in private subnets and use VPC endpoints to reach AWS services
    assign_public_ip = false
  }

  # Ignore external changes to desired_count to allow manual scaling without
  # Terraform reverting the count on the next apply
  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }

  tags = local.common_tags
}
