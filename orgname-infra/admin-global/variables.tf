# The account ID variables here need to have their defaults replaced
# with the actual account numbers that we get from the outputs in the
# org-root account's admin-global namespace.

variable "account_id_org_root" {
  description = "Account number for org-root account"
  type        = string
  default     = "PLACEHOLDER"
}

variable "email_org_root" {
  description = "Email address for org-root account"
  type        = string
  default     = "PLACEHOLDER"
}

variable "account_id_id" {
  description = "Account number for id account"
  type        = string
  default     = "PLACEHOLDER"
}

variable "email_id" {
  description = "Email address for id account"
  type        = string
  default     = "PLACEHOLDER"
}

variable "logging_bucket" {
  description = "S3 bucket for AWS logs"
  type        = string
  default     = "orgname-infra-aws-logs"
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}
