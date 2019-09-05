#
# AWS Account Alias One
#

resource "aws_organizations_account" "aws-account-alias-one" {
  name      = "${local.org_name}-aws-account-alias-one"
  email     = "${local.org_email_alias}+aws-account-alias-one@${local.org_email_domain}"
  parent_id = "${aws_organizations_organizational_unit.main.id}"
}
