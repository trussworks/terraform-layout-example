locals {
  region = "us-west-2"

  org_name         = "aws-org-name"
  org_email_domain = "truss.works"
  org_email_alias  = "aws-account-email-alias"
}

data "aws_caller_identity" "current" {}
data "aws_iam_account_alias" "current" {}


#
# AWS Logs
#

module "logs" {
  source              = "trussworks/logs/aws"
  version             = "3.4.0"
  default_allow       = false
  allow_cloudtrail    = true
  region              = "${local.region}"
  s3_bucket_name      = "${local.aws_logs_bucket_alias}"
  cloudtrail_accounts = "${concat([aws_organizations_organization.main.id], aws_organizations_organization.main.accounts[*].id)}"
}

#
# Cloudtrail
#

module "cloudtrail" {
  source             = "trussworks/cloudtrail/aws"
  version            = "2.0.0"
  encrypt_cloudtrail = true
  org_trail          = true
  s3_bucket_name     = "${module.logs.aws_logs_bucket}"
}
