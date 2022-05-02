data "aws_caller_identity" "current" {}

data "aws_iam_account_alias" "current" {}

#
# AWS Logs
#

module "logs" {
  source  = "trussworks/logs/aws"
  version = "13.0.0"

  default_allow = false

  allow_cloudtrail = true
  cloudtrail_accounts = concat(
    [
      aws_organizations_organization.main.id,
      data.aws_caller_identity.current.account_id
    ],
    aws_organizations_organization.main.accounts[*].id
  )

  s3_bucket_name = var.logging_bucket
}

#
# Cloudtrail
#

module "cloudtrail" {
  source         = "trussworks/cloudtrail/aws"
  version        = "4.3.0"
  org_trail      = true
  s3_bucket_name = module.logs.aws_logs_bucket
}

#
# Config
#

module "config" {
  source  = "trussworks/config/aws"
  version = "~> 4.0"

  config_name        = format("%s-config-%s", data.aws_iam_account_alias.current.account_alias, var.region)
  config_logs_bucket = module.logs.aws_logs_bucket

  aggregate_organization = true

  check_cloud_trail_encryption          = true
  check_cloud_trail_log_file_validation = true
  check_multi_region_cloud_trail        = true

  # This setting we *only* enable for the org-root account, because by
  # default, none of the subsidiary account root passwords are even set,
  # so no one can log in to them without jumping through the password
  # recovery hoops.
  check_root_account_mfa_enabled = true
}

#
# GuardDuty
#

# AWS best practice is that the GuardDuty admin account is not the org-root
# account, but one that is reserved for infra or security use. In our
# example here, that's the orgname-infra account. All other GuardDuty
# configuration is done in that account. See
# orgname-infra/admin-global/guardduty.tf for more information.

resource "aws_guardduty_organization_admin_account" "main" {
  depends_on = [aws_organizations_organization.main]

  admin_account_id = aws_organizations_account.orgname_infra.id
}
