data "aws_iam_account_alias" "current" {}

#
# Logs
#

module "logs" {
  source  = "trussworks/logs/aws"
  version = "~> 13.0.0"

  default_allow = false
  allow_config  = true

  allow_alb = true

  region         = var.region
  s3_bucket_name = var.logging_bucket
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
}

#
# GuardDuty
#

resource "aws_guardduty_detector" "member" {
  enable = true
}

resource "aws_guardduty_invite_accepter" "member" {
  detector_id       = aws_guardduty_detector.member.id
  master_account_id = var.account_id_org_root
}

# These modules allow groups from the id account to assume roles in this
# account to give them privileges.

module "infra_role" {
  source  = "trussworks/iam-cross-acct-dest/aws"
  version = "3.0.1"

  iam_role_name     = "infra"
  source_account_id = var.account_id_id
}

module "engineer_role" {
  source  = "trussworks/iam-cross-acct-dest/aws"
  version = "3.0.1"

  iam_role_name     = "engineer"
  source_account_id = var.account_id_id
}

# This is the prod account, so we need to be more restrictive with the
# permissions we give folks. Infra engineers will have power user access,
# but application engineers are only allowed to look at logs.

resource "aws_iam_role_policy_attachment" "infra_policy_attachment" {
  role       = module.infra_role.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

# This is still probably *too* permissive, since it grants access to
# *all* Cloudwatch logs; optimally, we'd give engineers a more specific
# policy that only covers the application logs. For demonstration purposes
# though, this is good enough.
resource "aws_iam_role_policy_attachment" "engineer_policy_attachment" {
  role       = module.engineer_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsReadOnlyAccess"
}
