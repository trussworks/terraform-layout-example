data "aws_caller_identity" "current" {}

data "aws_am_account_alias" "current" {}

#
# AWS Logs
#

module "logs" {
  source  = "trussworks/logs/aws"
  version = "8.0.0"

  default_allow       = false

  allow_cloudtrail    = true
  cloudtrail_accounts = concat(
    [
      aws_organizations_organization.main.id,
      data.aws_caller_identity.current.account_id
    ],
    aws_organizations_organization.main.accounts[*].id
  )

  region              = var.region
  s3_bucket_name      = var.logging_bucket
}

#
# Cloudtrail
#

module "cloudtrail" {
  source             = "trussworks/cloudtrail/aws"
  version            = "2.0.4"
  encrypt_cloudtrail = true
  org_trail          = true
  s3_bucket_name     = module.logs.aws_logs_bucket
}

#
# Config
#

module "config" {
  source  = "trussworks/config/aws"
  version = "~> 2.5"

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
  check_root_account_mfa_enabled        = true
}

#
# GuardDuty
#

resource "aws_guardduty_detector" "main" {
  enable = true
}

resource "aws_guardduty_member" "orgname-id" {
  account_id                 = aws_organizations_account.orgname-id.id
  detector_id                = aws_guardduty_detector.main.id
  email                      = aws_organizations_account.orgname-id.email
  invite                     = true
  invitation_message         = "please accept guardduty invitation"
  disable_email_notification = true
}

resource "aws_guardduty_member" "orgname-infra" {
  account_id                 = aws_organizations_account.orgname-infra.id
  detector_id                = aws_guardduty_detector.main.id
  email                      = aws_organizations_account.orgname-infra.email
  invite                     = true
  invitation_message         = "please accept guardduty invitation"
  disable_email_notification = true
}

resource "aws_guardduty_member" "orgname-sandbox" {
  account_id                 = aws_organizations_account.orgname-sandbox.id
  detector_id                = aws_guardduty_detector.main.id
  email                      = aws_organizations_account.orgname-sandbox.email
  invite                     = true
  invitation_message         = "please accept guardduty invitation"
  disable_email_notification = true
}

resource "aws_guardduty_member" "orgname-prod" {
  account_id                 = aws_organizations_account.orgname-prod.id
  detector_id                = aws_guardduty_detector.main.id
  email                      = aws_organizations_account.orgname-prod.email
  invite                     = true
  invitation_message         = "please accept guardduty invitation"
  disable_email_notification = true
}
