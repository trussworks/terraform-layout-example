# This module forces all specified users/groups to use MFA in order to
# do pretty much anything except set up MFA.
module "iam_enforce_mfa" {
  source  = "trussworks/mfa/aws"
  version = "~> 3.0.0"

  iam_groups = ["admins"]
  iam_users  = []
}

#
# Admin User/Group Setup
#

resource "aws_iam_user" "admins" {
  for_each      = toset(local.admin_users)
  name          = each.value
  force_destroy = true

  tags = {
    Automation = "Terraform"
  }
}

locals {
  admin_users = [
    "alice.org-root",
    "bob.org-root",
  ]
}

module "admins_group" {
  source  = "trussworks/iam-user-group/aws"
  version = "2.1.0"

  user_list     = local.admin_users
  group_name    = "admins"
  allowed_roles = ["admin", "billing"]
}

# This is a generic role assumption policy that enforces MFA.
data "aws_iam_policy_document" "role_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    # only allow folks in this account
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
    # require MFA
    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }
}

resource "aws_iam_role" "admin" {
  name               = "admin"
  description        = "Role for organization administrators"
  assume_role_policy = data.aws_iam_policy_document.role_assume_role_policy.json
  tags = {
    Automation = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "admin_administrator_access" {
  role       = aws_iam_role.admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

#
# Billing Role Setup
#

# This policy grants *only* billing access, so that we can give delivery
# and project managers access to a role with these permissions without
# giving them accounts.
data "aws_iam_policy_document" "limited_billing_access" {
  statement {
    sid    = "AllowAccessToBudgetsAndCostExplorer"
    effect = "Allow"
    actions = [
      "aws-portal:ViewBilling",
      "aws-portal:ViewUsage",
      "budgets:ViewBudget",
      "ce:View*",
      "pricing:*"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "DenyAccessToAccountAndPaymentMethod"
    effect = "Deny"
    actions = [
      "aws-portal:*Account",
      "aws-portal:*PaymentMethods",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "limited_billing_access" {
  name        = "limited-billing-access"
  path        = "/"
  description = "Allows limited billing access"
  policy      = data.aws_iam_policy_document.limited_billing_access.json
}

# This module gives the id account the ability to allow users to assume
# the billing role in this account.
module "billing_role_access" {
  source  = "trussworks/iam-cross-acct-dest/aws"
  version = "~> 3.0.0"

  iam_role_name     = "billing"
  source_account_id = aws_organizations_account.orgname_id.id
}
