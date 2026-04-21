# ecs-launchpad
ECS Launchpad is a Platform Engineering project demonstrating end-to-end cloud infrastructure on AWS. It gives developers a platform to automate containerized application deployments with observability. ECS Launchpad reduces infrastructure provisioning from hours to minutes using infrastructure as code.

My goal for this project is to apply the knowledge gained from my Platform Engineering internship and my time studying for the AWS Certified Solutions Architect Associate exam towards a real-world development platform. 

## Architecture
![Architecture Diagram](docs/architecture.png)

## Key Features

- Infrastructure as Code with Terraform modules
- Secure CI/CD using GitHub Actions and OIDC federation
- Containerized workloads deployed on ECS Fargate
- Production networking with ALB, Route53, TLS, and VPC endpoints
- Observability with CloudWatch metrics, logs, alarms, and dashboards
- Secure secrets management with AWS Secrets Manager

## Key Design Decisions
- **ECS Fargate**: serverless container runtime, removes the need to manage servers and simplifies scaling
- **ACM + Route53**: TLS certificate automatically provisioned and validated via DNS, HTTP redirected to HTTPS at the ALB
- **ALB**: layer 7 load balancing across ECS tasks with health-based routing and automatic target deregistration
- **Modular Terraform**: infrastructure is separated into focused, reusable modules per concern, making infrastructure easier to maintain and extend
- **Multi-stage Docker build**: drastically reduces image size, separates build dependencies from the runtime image, and reduces attack surface
- **Separated IAM roles**: task execution role and task role are decoupled. The execution role handles ECS startup concerns, the task role governs what the running application can access at runtime
- **CloudWatch Container Insights**: monitors CPU and memory at the task and service level using native AWS tooling
- **OIDC Federation**: GitHub Actions assumes a scoped IAM role via short-lived token, removing the need to store credentials

## Security

- GitHub Actions authenticates to AWS via OIDC federation (no stored credentials)
- Secrets stored in AWS Secrets Manager
- IAM roles follow least privilege principles
- TLS enforced via ACM certificates and ALB HTTPS redirect
- VPC endpoints enable private AWS service access without public internet exposure

## Tech Stack

| Layer | Technology |
|---|---|
| Application | Python 3.12, FastAPI |
| Containerization | Docker (multi-stage build) |
| Orchestration | AWS ECS Fargate |
| Container Registry | AWS ECR |
| Infrastructure-as-Code | Terraform |
| CI/CD | GitHub Actions |
| Networking | Route53, VPC, ALB, IGW, VPC Endpoints, Security Groups |
| Observability | CloudWatch Logs, Metrics, Alarms, Dashboard |
| Security | AWS Secrets Manager, IAM, ACM |

## Developer Workflow

ECS Launchpad is designed to minimize the steps required for developers to deploy and operate services.

### 1. Build & Push Code

Developers push changes to the `main` branch or create a pull request.

### 2. Automated CI Validation

GitHub Actions automatically:
- Validates Terraform configuration
- Builds the Docker image
- Runs a container smoke test

### 3. Continuous Deployment

On pushing a version tag to `main`:
- The application image is built and pushed to ECR
- ECS service is updated with the new task definition
- Rolling deployment replaces old tasks, minimizing downtime

### 4. Observability & Feedback

After deployment:
- Logs are available in CloudWatch Logs
- Metrics (CPU, memory) are visible in dashboards
- Alerts are triggered via SNS for critical failures

### 5. Rollback

Rollback is performed by redeploying a previous task definition revision.

## Terraform Module Architecture

The infrastructure is organized into reusable Terraform modules, each scoped to a single concern. This modular design enables independent testing, easier maintenance, and reuse across environments.

```
terraform/
├── main.tf             # Root module, wires all modules together          
├── providers.tf        # AWS provider and S3 backend config
├── variables.tf        # Customizable variables for provisioning
├── outputs.tf          # Necessary outputs for GitHub Actions
├── bootstrap           # Remote state (S3)
├── modules
│   ├── vpc             # Networking foundation (subnets, routing, IGW)
│   ├── vpc_endpoints   # Private AWS service access (no NAT required)
│   ├── ecr             # Container registry
│   ├── iam             # Least-privilege roles for ECS tasks
│   ├── alb             # Ingress (TLS, DNS, routing)
│   ├── ecs             # Application runtime (cluster, service, tasks)
│   ├── cloudwatch      # Runtime observability (alarms, dashboards)
│   ├── sns             # Email and text notifications for critical alarms 
│   └── github_actions  # OIDC provider and IAM roles for CI/CD
└── tests               # Integration tests per module
```

## Getting Started
### Prerequisites
- AWS CLI configured with permissions to deploy the infrastructure in this project
- An AWS account with a registered domain and a Route53 public hosted zone
- Terraform >= 1.14.8
- Docker

## Deployment 
### 1. Bootstrap Remote State (one time setup)

Before deploying any infrastructure, you need to provision the S3 bucket used for Terraform remote state.

```bash
cd terraform/bootstrap
cp terraform.tfvars.example terraform.tfvars  # edit values if needed
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

The `backend_config` output will be needed when running Step 2.

> [!NOTE]
> Secrets Manager enforces a 7 day recovery window on deletion by default. If you need to recreate a secret, force delete it first:
> ```bash
> aws secretsmanager delete-secret --secret-id <secret-id> --force-delete-without-recovery --region us-east-1
> ```

### 2. Deploy Infrastructure

```bash
cd terraform
cp backend.hcl.example backend.hcl       # fill in values from bootstrap output
cp terraform.tfvars.example terraform.tfvars  # fill in your values
terraform init -backend-config=backend.hcl
terraform plan -out=tfplan
terraform apply tfplan
```

> [!NOTE]
> Use a placeholder image (e.g. `public.ecr.aws/nginx/nginx:latest`) for `container_image` on the initial deployment. Once ECR is created, push your real image and the CD pipeline will handle subsequent deployments.

### 3. Update GitHub Repository Variables

After apply, set the following from Terraform outputs:

| Variable | Value |
|---|---|
| `AWS_ROLE_ARN` | `terraform output github_actions_role_arn` |
| `AWS_REGION` | your AWS region (e.g. `us-east-1`) |
| `ECR_REPOSITORY` | `terraform output ecr_repository_name` |
| `ECS_CLUSTER` | `terraform output ecs_cluster_name` |
| `ECS_SERVICE` | `terraform output ecs_service_name` |
| `ECS_TASK_DEFINITION` | `terraform output ecs_task_definition_family` |
| `CONTAINER_NAME` | `terraform output container_name` |
| `STATE_BUCKET_NAME` | `terraform output state_bucket_name` from bootstrap |
| `DOMAIN_NAME` | your root domain (e.g. `example.com`) |
| `SUBDOMAIN` | your full subdomain (e.g. `api.example.com`) |

### 4. Trigger Initial Deployment

Push a version tag on `main` to trigger the CD workflow. This will build your application image, push it to ECR, and deploy it to ECS, replacing the placeholder image from the initial `terraform apply`.

```bash
git tag v1.0.0
git push origin v1.0.0
```

> [!NOTE]
> CD only deploys tags that point to commits on `main`. Pushing a version tag on a feature branch will fail the pipeline. To make infrastructure changes, modify the relevant Terraform module, open a PR (CI will run `terraform plan`), then run `terraform apply` manually after merging.

## CI/CD

CI runs on every branch push and pull request to `main`, performing Terraform validation and a local Docker smoke test. Pushing a 
version tag (e.g. `v1.0.0`) on `main` triggers the CD workflow, which builds and pushes the image to ECR and deploys to ECS.

## Integration Tests
Each module has an integration test harness under `terraform/tests/`. For end to end validation, use the `terraform/tests/fullstack`, see its README for prerequisites and instructions. 

## Roadmap

### Planning stage
- [x] Architecture design and README
### Application 
- [x] FastAPI application
- [x] Dockerfile
### Core Infrastructure
- [x] Terraform bootstrap module
- [x] Terraform VPC module
- [x] Terraform VPC Endpoints module
- [x] Terraform ECR module
- [x] Terraform IAM module
- [x] Terraform ALB module
- [x] Terraform ECS module
### Observability
- [x] CloudWatch Logs, Metrics, and Alarms
- [x] CloudWatch Dashboard
- [x] SNS Notifications
### CI/CD
- [x] GitHub Actions CI/CD Pipeline
### Deployment
- [x] Live deployment

## Future Improvements
- [ ] Staging environment with automated promotion pipeline from staging to production
- [ ] Blue/green deployments with CodeDeploy
- [ ] Add auto-scaling policies based on ALB request count
- [ ] Add an RDS module for persistent storage
- [ ] Implement AWS WAF on the ALB for basic DDoS protection
- [ ] VPC Flow Logs for network traffic auditing
- [ ] Distributed tracing with AWS X-Ray
- [ ] Add EKS support for Kubernetes-native orchestration
