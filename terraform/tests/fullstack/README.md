# Full Stack Integration Test

This test harness deploys the full ECS stack including VPC, VPC Endpoints, ALB, IAM, ECS, CloudWatch, and SNS to validate end to end wiring.

## Prerequisites

Before running this test, the ECR repository must exist and contain a valid application image:

1. Run `tests/ecr` to create the ECR repository:
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

3. Pre-flight validation:
    ```bash
    aws ecr describe-images \
        --repository-name ecs-launchpad-test \
        --region us-east-1
    ```

4. Copy `terraform.tfvars.example` to `terraform.tfvars` and fill in your values

## Running

```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
terraform destroy
```

## Verifying

After apply, confirm the following:

- Your registered domain returns a valid HTTPS response
- ECS service shows tasks as healthy in the AWS console
- CloudWatch dashboard is visible under `CloudWatch > Dashboards`
- SNS subscription confirmation email arrives (if `email_subscriptions` is set)

> [!WARNING]
> Interface VPC endpoints and the ALB incur hourly charges. Destroy promptly after verifying.
