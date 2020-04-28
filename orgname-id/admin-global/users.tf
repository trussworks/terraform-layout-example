#
# IAM Users, Groups, and Roles
#

# Generic role assumption policy requiring MFA
data "aws_iam_policy_document" "role_assume_role_policy" {
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
  version = "~>1.0.0"

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

module "infra_group" {
  source  = "trussworks/iam-user-group/aws"
  version = "1.0.2"

  user_list     = local.infra_users
  allowed_roles = [module.infra_group_role.arn]
  group_name    = "infra"
}

module "billing_group" {
  source  = "trussworks/iam-user-group/aws"
  version = "1.0.2"

  user_list     = local.billing_users
  allowed_roles = [module.billing_group_role.arn]
  group_name    = "billing"
}

module "engineers_group" {
  source  = "trussworks/iam-user-group/aws"
  version = "1.0.2"

  user_list     = local.engineer_users
  allowed_roles = [module.engineer_group_role.arn]
  group_name    = "engineers"
}

# These modules allow the users in the various groups to assume roles
# in the other accounts of the organization; see the README for the
# module at https://github.com/trussworks/terraform-aws-iam-cross-acct-src

module "infra_role" {
  source  = "trussworks/iam-cross-acct-src/aws"
  version = "1.0.0"

  destination_account_ids = [
    data.aws_caller_identity.current.account_id,
    var.account_id_infra,
    var.account_id_sandbox,
    var.account_id_prod,
  ]

  destination_group_role = "infra"
}

module "billing_role" {
  source  = "trussworks/iam-cross-acct-src/aws"
  version = "1.0.0"

  destination_account_ids = [
    var.account_id_org_root,
  ]

  destination_group_role = "billing"
}

module "engineer_role" {
  source  = "trussworks/iam-cross-acct-src/aws"
  version = "1.0.0"

  destination_account_ids = [
    var.account_id_sandbox,
    var.account_id_prod,
  ]

  destination_group_role = "engineer"
}

# This gives infra users power user access in the id account.
resource "aws_iam_role_policy_attachment" "infra_local_policy_attachment" {
  role       = module.infra_role.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}
