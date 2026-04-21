data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

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

# Register GitHub Actions as a trusted OIDC identity provider
# This allows GitHub Actions workflows to assume AWS IAM roles via short lived 
# tokens instead of storing long lived AWS credentials 
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  # GitHub Actions OIDC thumbprint 
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]

  tags = local.common_tags
}

# IAM role assumed by GitHub Actions workflows via OIDC federation.
# Scoped to a specific repository and branch to prevent other repositories
# from assuming this role.
resource "aws_iam_role" "github_actions" {
  name = "${var.project_name}-${var.environment}-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowGitHubActionsOIDC"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            # Scope to the specific repository to prevent other repos from assuming this role
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repository}:*"
          }
        }
      }
    ]
  })

  tags = local.common_tags
}

# Inline policy granting the least privilege needed for continuous deployments
# ECR: authentication and image push
# ECS: service update to trigger a new deployment
resource "aws_iam_role_policy" "github_actions" {
  name = "${var.project_name}-${var.environment}-github-actions-policy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowECRAuth"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]

        # GetAuthorizationToken cannot be scoped to a specific repository
        Resource = "*"
      },
      {
        Sid    = "AllowECRPush"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]

        # Scoped to the specific ECR repository
        Resource = var.ecr_repository_arn
      },
      {
        Sid    = "AllowECSDeploy"
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition"
        ]
        Resource = [
          "arn:aws:ecs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:service/${var.ecs_cluster_name}/${var.ecs_service_name}",
          "arn:aws:ecs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:task-definition/${var.project_name}-${var.environment}:*"
        ]
      },
      {
        Sid    = "AllowPassExecutionRole"
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = [
          var.ecs_execution_role_arn,
          var.ecs_task_role_arn
        ]
      }
    ]
  })
}

# Scoped read only policy for terraform plan in CI
# Uses explicit actions per service rather than ReadOnlyAccess to follow least privilege
resource "aws_iam_role_policy" "github_actions_plan" {
  name = "${var.project_name}-${var.environment}-github-actions-plan-policy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowTerraformPlanRead"
        Effect = "Allow"
        Action = [
          # STS: required for data.aws_caller_identity
          "sts:GetCallerIdentity",

          # EC2: VPC, subnets, security groups, route tables, endpoints
          "ec2:Describe*",

          # ECR
          "ecr:Describe*",
          "ecr:List*",
          "ecr:GetRepositoryPolicy",
          "ecr:GetLifecyclePolicy",

          # ECS
          "ecs:Describe*",
          "ecs:List*",

          # IAM
          "iam:Get*",
          "iam:List*",

          # ALB
          "elasticloadbalancing:Describe*",

          # CloudWatch
          "cloudwatch:Describe*",
          "cloudwatch:List*",
          "cloudwatch:Get*",

          # CloudWatch Logs
          "logs:Describe*",
          "logs:List*",

          # SNS
          "sns:Get*",
          "sns:List*",

          # Secrets Manager
          "secretsmanager:Describe*",
          "secretsmanager:List*",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",

          # Route53
          "route53:Get*",
          "route53:List*",

          # ACM
          "acm:Describe*",
          "acm:List*",

          # S3 for terraform remote state
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = "*"
      }
    ]
  })
}
