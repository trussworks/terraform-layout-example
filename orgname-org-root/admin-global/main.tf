data "aws_caller_identity" "current" {}

#
# AWS Logs
#

module "logs" {
  source  = "trussworks/logs/aws"
  version = "8.0.0"

  default_allow       = false

  allow_cloudtrail    = true
  cloudtrail_accounts = "${concat([aws_organizations_organization.main.id], aws_organizations_organization.main.accounts[*].id)}"

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
