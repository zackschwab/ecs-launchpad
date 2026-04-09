output "state_bucket_name" {
  description = "Name of the S3 bucket used for Terraform remote state"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "state_bucket_arn" {
  description = "ARN of the S3 state bucket"
  value       = aws_s3_bucket.terraform_state.arn
}

output "backend_config" {
  description = "Backend block for all downstream modules"
  value       = <<-EOT
    terraform {
      backend "s3" {
        bucket         = "${aws_s3_bucket.terraform_state.bucket}"
        key            = "<module>/terraform.tfstate"
        region         = "${var.aws_region}"
        use_lockfile   = true
        encrypt        = true
      }
    }
  EOT
}
