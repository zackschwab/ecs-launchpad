output "repository_url" {
  description = "URL of the ECR repository, used by CI/CD to push images and ECS to pull them"
  value       = aws_ecr_repository.this.repository_url
}

output "repository_name" {
  description = "Name of the ECR repository"
  value       = aws_ecr_repository.this.name
}

output "repository_arn" {
  description = "ARN of the ECR repository, used to scope IAM policies"
  value       = aws_ecr_repository.this.arn
}