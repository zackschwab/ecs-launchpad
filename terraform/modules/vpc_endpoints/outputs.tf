output "vpc_endpoint_security_group_id" {
  description = "ID of the shared security group attached to all Interface VPC endpoints"
  value       = aws_security_group.vpc_endpoints.id
}
