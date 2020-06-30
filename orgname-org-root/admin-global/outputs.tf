# We need to have outputs for all these accounts because we need to
# know the account numbers when we're setting up things in other
# accounts.
output "aws_organizations_account_orgname_org_root_id" {
  description = "Account number for the orgname-org-root account"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_organizations_account_orgname_id_id" {
  description = "Account number for the orgname-id account"
  value       = aws_organizations_account.orgname_id.id
}

output "aws_organizations_account_orgname_infra_id" {
  description = "Account number for the orgname-infra account"
  value       = aws_organizations_account.orgname_infra.id
}

output "aws_organizations_account_orgname_sandbox_id" {
  description = "Account number for the orgname-sandbox account"
  value       = aws_organizations_account.orgname_sandbox.id
}

output "aws_organizations_account_orgname_prod_id" {
  description = "Account number for the orgname-prod account"
  value       = aws_organizations_account.orgname_prod.id
}
