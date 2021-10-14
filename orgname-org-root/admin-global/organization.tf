#
# AWS Organizations
#

resource "aws_organizations_organization" "main" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
  ]

  feature_set = "ALL"
}

#
# Primary organizations OU
#

# This OU will contain all our useful accounts and allows us to implement
# organization-wide policies easily.
resource "aws_organizations_organizational_unit" "main" {
  name      = var.org_name
  parent_id = aws_organizations_organization.main.roots.0.id
}

#
# Suspended organization OU
#

# This OU is for locking down accounts we believe are compromised or which
# should not contain any actual resources (like GovCloud placeholders).
resource "aws_organizations_organizational_unit" "suspended" {
  name      = "suspended"
  parent_id = aws_organizations_organization.main.roots.0.id
}

# The org-scp module lets us add some common SCPs to our organization;
# see the README at https://github.com/trussworks/terraform-aws-org-scp
module "org_scps" {
  source  = "trussworks/org-scp/aws"
  version = "~> 1.6.0"

  deny_root_account_target_ids     = [aws_organizations_organizational_unit.main.id]
  deny_leaving_orgs_target_ids     = [aws_organizations_organizational_unit.main.id]
  require_s3_encryption_target_ids = [aws_organizations_organizational_unit.main.id]

  deny_all_access_target_ids = [aws_organizations_organizational_unit.suspended.id]
}

#
# AWS Organization Accounts
#

resource "aws_organizations_account" "orgname_id" {
  name      = format("%s-id", var.org_name)
  email     = format("%s+id@%s", var.org_email_alias, var.org_email_domain)
  parent_id = aws_organizations_organizational_unit.main.id

  # We allow IAM users to access billing from the id account so that we
  # can give delivery/project managers access to billing data without
  # giving them full access to the org-root account.
  iam_user_access_to_billing = "ALLOW"

  tags = {
    Automation = "Terraform"
  }
}

resource "aws_organizations_account" "orgname_infra" {
  name      = format("%s-infra", var.org_name)
  email     = format("%s+infra@%s", var.org_email_alias, var.org_email_domain)
  parent_id = aws_organizations_organizational_unit.main.id

  iam_user_access_to_billing = "DENY"

  tags = {
    Automation = "Terraform"
  }
}

resource "aws_organizations_account" "orgname_sandbox" {
  name      = format("%s-sandbox", var.org_name)
  email     = format("%s+sandbox@%s", var.org_email_alias, var.org_email_domain)
  parent_id = aws_organizations_organizational_unit.main.id

  iam_user_access_to_billing = "DENY"

  tags = {
    Automation = "Terraform"
  }
}

resource "aws_organizations_account" "orgname_prod" {
  name      = format("%s-prod", var.org_name)
  email     = format("%s+prod@%s", var.org_email_alias, var.org_email_domain)
  parent_id = aws_organizations_organizational_unit.main.id

  iam_user_access_to_billing = "DENY"

  tags = {
    Automation = "Terraform"
  }
}
