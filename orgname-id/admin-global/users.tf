#
# IAM Users, Groups, and Roles
#

# Generic role assumption policy requiring MFA
data "aws_iam_policy_document" "user_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    # only allow folks in this account
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
    # only allow folks with MFA
    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }
}

# This module enforces MFA; any groups defined in this file should
# be added to the iam_groups argument.
module "iam_enforce_mfa" {
  source  = "trussworks/mfa/aws"
  version = "~> 3.0.0"

  iam_groups = ["infra", "engineers", "billing"]
  iam_users  = []
}

locals {
  infra_users = [
    "alice",
    "bob",
  ]

  billing_users = [
    "charlie",
  ]

  engineer_users = [
    "donna",
    "edward",
  ]
}

resource "aws_iam_user" "infra_users" {
  for_each      = toset(local.infra_users)
  name          = each.value
  force_destroy = true

  tags = {
    Automation = "Terraform"
  }
}

resource "aws_iam_user" "billing_users" {
  for_each      = toset(local.billing_users)
  name          = each.value
  force_destroy = true

  tags = {
    Automation = "Terraform"
  }
}

resource "aws_iam_user" "engineer_users" {
  for_each      = toset(local.engineer_users)
  name          = each.value
  force_destroy = true

  tags = {
    Automation = "Terraform"
  }
}

# Here we're defining the groups for the users we created above using
# the Truss module for this purpose. Note that we are specifying roles
# *outside* this account that these users can assume; these will be
# defined in those accounts with the Truss' iam-cross-acct-dest module.
# Doing the role assumption this way avoids the role-chaining we used
# to use, that would sometimes cause problems (and force short sessions).

module "infra_group" {
  source  = "trussworks/iam-user-group/aws"
  version = "2.1.0"

  user_list = local.infra_users
  allowed_roles = [
    aws_iam_role.infra.arn,
    "arn:aws:iam::${var.account_id_infra}:role/infra",
    "arn:aws:iam::${var.account_id_sandbox}:role/infra",
    "arn:aws:iam::${var.account_id_prod}:role/infra",
  ]
  group_name = "infra"
}

module "billing_group" {
  source  = "trussworks/iam-user-group/aws"
  version = "2.1.0"

  user_list = local.billing_users
  allowed_roles = [
    "arn:aws:iam::${var.account_id_org_root}:role/billing",
  ]
  group_name = "billing"
}

module "engineers_group" {
  source  = "trussworks/iam-user-group/aws"
  version = "2.1.0"

  user_list = local.engineer_users
  allowed_roles = [
    aws_iam_role.engineer.arn,
    "arn:aws:iam::${var.account_id_sandbox}:role/engineer",
    "arn:aws:iam::${var.account_id_prod}:role/engineer",
  ]
  group_name = "engineer"
}

# These roles are users locally in the id account; note that the billing
# group has no role in this account, since they don't need it -- there's
# no billing data here in the id account, they just need to be able to
# get it from the org-root account.

resource "aws_iam_role" "infra" {
  name               = "infra"
  assume_role_policy = data.aws_iam_policy_document.user_assume_role_policy.json
}

resource "aws_iam_role" "engineer" {
  name               = "engineer"
  assume_role_policy = data.aws_iam_policy_document.user_assume_role_policy.json
}

# This gives infra users power user access in the id account.
resource "aws_iam_role_policy_attachment" "infra_local_policy_attachment" {
  role       = aws_iam_role.infra.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

# This gives engineers view-only access in the id account.
resource "aws_iam_role_policy-attachment" "engineer_local_policy_attachment" {
  role       = aws_iam_role.engineer.name
  policy_arn = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
}
