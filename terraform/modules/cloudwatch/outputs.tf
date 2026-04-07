output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.this.dashboard_name
}

output "cpu_alarm_arn" {
  description = "ARN of the ECS CPU utilization alarm"
  value       = aws_cloudwatch_metric_alarm.ecs_cpu.arn
}

output "memory_alarm_arn" {
  description = "ARN of the ECS memory utilization alarm"
  value       = aws_cloudwatch_metric_alarm.ecs_memory.arn
}

output "alb_5xx_alarm_arn" {
  description = "ARN of the ALB 5xx error alarm"
  value       = aws_cloudwatch_metric_alarm.alb_5xx.arn
}

output "unhealthy_hosts_alarm_arn" {
  description = "ARN of the unhealthy hosts alarm"
  value       = aws_cloudwatch_metric_alarm.unhealthy_hosts.arn
}
