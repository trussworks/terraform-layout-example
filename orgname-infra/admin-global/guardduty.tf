# Because this account is the GuardDuty admin account (see the configs
# in orgname-org-root/admin-global/main.tf), most of the GuardDuty
# configuration is done here, and all findings are consolidated in this
# account as well.

# GuardDuty is a region-based service, so for each region we want to get
# GuardDuty notifications for, we need to set up a set of resources.

# The detector is the main component of GuardDuty -- this is what actually
# "turns it on" for an account. We only need to create a detector here in
# the GuardDuty admin account; other accounts will get detectors created
# automatically when we add them as members later.

resource "aws_guardduty_detector" "main_uswest2" {
  enable = true
}

resource "aws_guardduty_detector" "main_useast1" {
  provider = aws.us-east-1

  enable = true
}

# The organization configuration is what links other accounts in the
# organization to this one -- this is done by linking detectors in
# the other accounts to this one. Note the `auto_enable = true` option
# means than any *new* accounts we create will automatically be added
# as members, but accounts we created prior to setting up GuardDuty for
# the organization will need to be added manually.

resource "aws_guardduty_organization_configuration" "main_uswest2" {
  auto_enable = true
  detector_id = aws_guardduty_detector.main_uswest2.id
}

resource "aws_guardduty_organization_configuration" "main_useast1" {
  provider = aws.us-east-1

  auto_enable = true
  detector_id = aws_guardduty_detector.main_useast1.id
}

# This module directs GuardDuty notifications to Slack and/or PagerDuty;
# we're going to just send them to Slack here, but they *should* be
# infrequent enough that you could send them to PagerDuty without adding
# too much of a burden on your on-call team.

module "guardduty_notifications_uswest2" {
  source  = "trussworks/guardduty-notifications/aws"
  version = "~> 5.0.0"

  pagerduty_notifications = false

  sns_topic_slack = aws_sns_topic.notify_slack_uswest2
}

module "guardduty_notifications_useast1" {
  providers = {
    aws = aws.us-east-1
  }

  source  = "trussworks/guardduty-notifications/aws"
  version = "~> 5.0.0"

  pagerduty_notifications = false

  sns_topic_slack = aws_sns_topic.notify_slack_useast1
}

# Because we already created our org-root and id accounts before we created
# the infra account and set up GuardDuty, we have to add them to the
# GuardDuty configuration as members. However, since we created the sandbox
# and prod accounts *after* the infra account and after we set up our
# GuardDuty configuration, they got added to the GuardDuty configuration
# automatically.

# To add the accounts we already have, we need the following resources to
# be defined, but due to a bug in the AWS Terraform provider, it will try to
# destroy and then recreate them every time we run Terraform in this namespace.
# So instead, we comment these out after the first run. This will not actually
# remove them as members (you can confirm that with the AWS commands).
# See https://github.com/terraform-providers/terraform-provider-aws/issues/13906

# resource "aws_guardduty_member" "orgname_org_root_uswest2" {
#   account_id                 = var.account_id_org_root
#   detector_id                = aws_guardduty_detector.main_uswest2
#   email                      = var.email_org_root
#   invite                     = false
#   disable_email_notification = true
# }

# resource "aws_guardduty_member" "orgname_org_root_useast1" {
#   provider                   = aws.us-east-1
#   account_id                 = var.account_id_org_root
#   detector_id                = aws_guardduty_detector.main_useast1
#   email                      = var.email_org_root
#   invite                     = false
#   disable_email_notification = true
# }

# resource "aws_guardduty_member" "orgname_id_uswest2" {
#   account_id                 = var.account_id_id
#   detector_id                = aws_guardduty_detector.main_uswest2
#   email                      = var.email_id
#   invite                     = false
#   disable_email_notification = true
# }

# resource "aws_guardduty_member" "orgname_id_useast1" {
#   provider                   = aws.us-east-1
#   account_id                 = var.account_id_id
#   detector_id                = aws_guardduty_detector.main_useast1
#   email                      = var.email_id
#   invite                     = false
#   disable_email_notification = true
# }
