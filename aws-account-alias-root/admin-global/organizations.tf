#
# AWS Organizations
#

resource "aws_organizations_organization" "main" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
  ]

  feature_set = "ALL"
}

#
# Primary organizations OU
#

resource "aws_organizations_organizational_unit" "main" {
  name      = "${local.org_name}"
  parent_id = "${aws_organizations_organization.main.roots.0.id}"
}

#
# Suspended organization OU
#

resource "aws_organizations_organizational_unit" "suspend" {
  name      = "suspended"
  parent_id = "${aws_organizations_organization.main.roots.0.id}"
}

data "aws_iam_policy_document" "suspend" {
  statement {
    sid = "1"

    effect = "Deny"

    actions = [
      "*"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_organizations_policy" "suspended" {
  name = "suspended"

  content = "${data.aws_iam_policy_document.suspend.json}"

  type = "SERVICE_CONTROL_POLICY"
}
