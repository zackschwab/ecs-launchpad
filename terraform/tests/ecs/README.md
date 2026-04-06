# ECS Integration Test

This test harness deploys the full ECS stack including VPC, VPC Endpoints, ALB, IAM, and ECS.

## Prerequisites

Before running this test, the ECR repository must exist and contain a valid application image:

1. Run `tests/ecr` to create the repository:
```bash
   cd tests/ecr
   terraform init
   terraform plan -out=tfplan
   terraform apply tfplan
```

2. Build and push your application image:
```bash
    ECR_URL=$(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com
    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_URL
    docker build -t ecs-launchpad-test .
    docker tag ecs-launchpad-test:latest $ECR_URL/ecs-launchpad-test:latest
    docker push $ECR_URL/ecs-launchpad-test:latest
```

3. Copy `terraform.tfvars.example` to `terraform.tfvars` and set `container_image`

## Running
```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
terraform destroy
```

> [!WARNING]
> Interface VPC Endpoints incur hourly charges. Destroy promptly after verifying. 