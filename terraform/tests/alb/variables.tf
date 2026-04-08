variable "domain_name" {
  description = "Root domain name of the Route53 hosted zone"
  type        = string
}

variable "subdomain" {
  description = "Full subdomain to point at the ALB"
  type        = string
}
