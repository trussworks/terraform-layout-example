data "aws_caller_identity" "current" {}

#
# Logs
#

module "logs" {
  source  = "trussworks/logs/aws"
  version = "~> 8.0.0"

  default_allow = false
  allow_config  = true

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
