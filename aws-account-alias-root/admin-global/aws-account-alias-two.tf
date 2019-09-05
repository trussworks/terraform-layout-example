#
# AWS Account Alias Two
#

resource "aws_organizations_account" "aws-account-alias-two" {
  name      = "${local.org_name}-aws-account-alias-two"
  email     = "${local.org_email_alias}+aws-account-alias-two@${local.org_email_domain}"
  parent_id = "${aws_organizations_organizational_unit.main.id}"
}
