# GitHub Actions Integration Test

Creates the OIDC provider and IAM role that GitHub Actions workflows use to authenticate with AWS.

## Prerequisites

This module has no Terraform dependencies and can be applied standalone. However, before the CD workflow can deploy, run `tests/fullstack` to create the ECS cluster, service, and ECR repository.

## Running

```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
terraform destroy
```

## After Apply

Set the following variables in your GitHub repository under Settings > Secrets and Variables > Actions > Repository Variables:

| Variable | Default Value |
|---|---|
| `AWS_ROLE_ARN` | The `role_arn` output from this module |
| `AWS_REGION` | `us-east-1` |
| `ECR_REPOSITORY` | `ecs-launchpad-test` |
| `ECS_CLUSTER` | `ecs-launchpad-test` |
| `ECS_SERVICE` | `ecs-launchpad-test` |
| `ECS_TASK_DEFINITION` | `ecs-launchpad-test` |
| `CONTAINER_NAME` | `ecs-launchpad` |

> [!NOTE]
> `AWS_ROLE_ARN` and `AWS_REGION` are sufficient to run the CI workflow. The remaining variables are only required for the CD workflow.

> [!WARNING]
> If the OIDC provider already exists in your account, import it before applying:
> ```bash
> terraform import module.github_actions.aws_iam_openid_connect_provider.github \
>   arn:aws:iam::<account_id>:oidc-provider/token.actions.githubusercontent.com
> ```
