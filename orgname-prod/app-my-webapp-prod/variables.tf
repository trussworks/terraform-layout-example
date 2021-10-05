variable "environment" {
  type = string
}

variable "logging_bucket" {
  description = "S3 bucket for AWS logging"
  type        = string
  default     = "orgname-prod-aws-logs"
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}

variable "zone_name" {
  description = "DNS zone name"
  type        = string
  default     = "prod.example.com."
}
