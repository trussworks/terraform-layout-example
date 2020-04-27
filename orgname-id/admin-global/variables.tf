# The account ID variables here need to have their defaults replaced
# with the actual account numbers that we get from the outputs in the
# org-root account's admin-global namespace.

variable "account_id_org_root" {
  description = "Account number for org-root account"
  type        = string
  default     = "PLACEHOLDER"
}

variable "account_id_infra" {
  description = "Account number for the infra account"
  type        = string
  default     = "PLACEHOLDER"
}

variable "account_id_sandbox" {
  description = "Account number for the sandbox account"
  type        = string
  default     = "PLACEHOLDER"
}

variable "account_id_prod" {
  description = "Account numbeer for the prod account"
  type        = string
  default     = "PLACEHOLDER"
}

variable "logging_bucket" {
  description = "S3 bucket for AWS logs"
  type        = string
  default     = "orgname-id-aws-logs"
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}
