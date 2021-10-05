# This creates a sandbox DNS domain so that we can allocate DNS for our
# dev deployments. See the other part of this configuration in
# orgname-infra/admin-global/dns.tf.
resource "aws_route53_zone" "sandbox_example_com" {
  name = "sandbox.example.com."
}

# We output these so that we can add them to the orgname-infra DNS config.
output "sandbox_example_com_nameservers" {
  value = aws_route53_zone.sandbox_example_com.name_servers
}

# Add query logging to our zone.
module "sandbox_example_com_query_logging" {
  source  = "trussworks/route53-query-logs/aws"
  version = "~> 3.1.0"

  # See orgname-infra/admin-global/dns.tf for an explanation of this line.
  providers = { aws.us-east-1 = aws.us-east-1 }

  zone_id                   = aws_route53_zone.sandbox_example_com.zone_id
  logs_cloudwatch_retention = var.log_retention_days
}
