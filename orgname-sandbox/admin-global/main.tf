locals {
  orgname_org_root_account_id = <org-root-account-number>
  orgname_id_account_id       = <id-account-number>
}

#
# Logs
#

module "logs" {
  source  = "trussworks/logs/aws"
  version = "~> 8.0.0"

  default_allow = false
  allow_config  = true
  
  allow_alb     = true

  region         = var.region
  s3_bucket_name = var.logging_bucket
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
  version = "1.0.3"

  iam_role_name             = "infra"
  source_account_id         = var.account_id_id
}

module "engineer_role" {
  source  = "trussworks/iam-cross-acct-dest/aws"
  version = "1.0.3"

  iam_role_name             = "engineer"
  source_account_id         = var.account_id_id
}

# Because this is the sandbox account, we're going to give both infra and
# application engineers power user access in this account.

resource "aws_iam_role_policy_attachment" "infra_policy_attachment" {
  role       = module.infra_role.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_role_policy_attachment" "engineer_policy_attachment" {
  role       = module.engineer_role.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}
