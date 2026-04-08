output "alb_arn" {
  description = "ARN of the ALB"
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.this.dns_name
}

output "target_group_arn" {
  description = "ARN of the target group, passed to the ECS service for task registration"
  value       = aws_lb_target_group.this.arn
}

output "alb_security_group_id" {
  description = "Security group ID of the ALB, passed to the ECS module to scope task ingress"
  value       = aws_security_group.alb.id
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener"
  value       = aws_lb_listener.https.arn
}

output "alb_arn_suffix" {
  description = "ARN suffix of the ALB, used to scope CloudWatch ALB metrics"
  value       = aws_lb.this.arn_suffix
}

output "target_group_arn_suffix" {
  description = "ARN suffix of the target group, used to scope CloudWatch target group metrics"
  value       = aws_lb_target_group.this.arn_suffix
}
