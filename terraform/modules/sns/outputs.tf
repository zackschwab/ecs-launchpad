output "topic_arn" {
  description = "ARN of the SNS alerts topic, passed to the CloudWatch module to wire alarm actions"
  value       = aws_sns_topic.this.arn
}

output "topic_name" {
  description = "Name of the SNS alerts topic"
  value       = aws_sns_topic.this.name
}
