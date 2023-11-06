data "aws_caller_identity" "current" {}

data "aws_iam_account_alias" "current" {}

#
# Logs
#

module "logs" {
  source  = "trussworks/logs/aws"
  version = "~> 16.2.0"

  default_allow = false
  allow_config  = true

  region         = var.region
  s3_bucket_name = var.logging_bucket
}

#
# Config
#

module "config" {
  source  = "trussworks/config/aws"
  version = "~> 8.0"

  config_name        = format("%s-config-%s", data.aws_iam_account_alias.current.account_alias, var.region)
  config_logs_bucket = module.logs.aws_logs_bucket

  aggregate_organization = true

  check_cloud_trail_encryption          = true
  check_cloud_trail_log_file_validation = true
  check_multi_region_cloud_trail        = true
}
