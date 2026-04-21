output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.this.arn
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.this.name
}

output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.this.name
}

output "task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = aws_ecs_task_definition.this.arn
}

output "ecs_security_group_id" {
  description = "Security group ID for ECS tasks, passed to the vpc_endpoints module"
  value       = aws_security_group.ecs.id
}

output "log_group_name" {
  description = "Name of the CloudWatch log group for container logs"
  value       = aws_cloudwatch_log_group.this.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group, used to scope IAM policies"
  value       = aws_cloudwatch_log_group.this.arn
}

output "task_definition_family" {
  description = "ECS task definition family name"
  value       = aws_ecs_task_definition.this.family
}

output "container_name" {
  description = "Container name used in the task definition"
  value       = var.project_name
}
