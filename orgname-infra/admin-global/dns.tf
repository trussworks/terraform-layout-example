# Here we can define a zone in Route53 that we can use for deploying our
# applications. We will make the *zone* here, then farm out subdomains to
# other accounts if we so desire.

# Create the zone itself.
resource "aws_route53_zone" "example_com" {
  name = "example.com."
}

# We're also going to add an output here that will list the nameservers
# for our domain. We'll need to add that to records in other namespaces.
output "example_com_nameservers" {
  value = aws_route53_zone.example_com.name_servers
}

# Add query logging to our zone.
module "example_com_query_logging" {
  source  = "trussworks/route53-query-logs/aws"
  version = "~> 3.1.0"

  # Route53 is *only* available in us-east-1, so we need to use a special
  # provider for this resource. We also need to define this in providers.tf;
  # see that file for the other half of this step.
  providers = { aws.us-east-1 = aws.us-east-1 }

  zone_id                   = aws_route53_zone.example_com.zone_id
  logs_cloudwatch_retention = var.log_retention_days
}

# Delegate sandbox.example.com to the sandbox nameservers; we have to get
# these from the output of the DNS components in the orgname-sandbox account.
resource "aws_route53_record" "sandbox_example_com" {
  allow_overwrite = true
  name            = "sandbox.example.com"
  ttl             = 3600
  type            = "NS"
  zone_id         = aws_route53_zone.example_com.zone_id

  # These are the records we got from sandbox; these are just examples,
  # you will need to get the real outputs from that account.
  records = [
    "fake.awsdns.org",
    "dummy.awsdns.com",
    "notreal.awsdns.co.uk",
    "placeholder.awsdns.net",
  ]
}

# We are going to add a prod.example.com domain as well for the prod
# environment. This will let the prod instance of our webapp create DNS
# entries for its ALB and ACM validation without giving it access to
# our root domain. We'll need to get the DNS records from the prod account
# the same way we did for sandbox.
resource "aws_route53_record" "prod_example_com" {
  allow_overwrite = true
  name            = "prod.example.com"
  ttl             = 3600
  type            = "NS"
  zone_id         = aws_route53_zone.example_com.zone_id

  # These are records from prod; these are just examples, you will need
  # to get the real outputs from that account.
  records = [
    "stillfake.awsdns.org",
    "notmydns.awsdns.com",
    "notreally.awsdns.co.uk",
    "notdns.awsdns.net",
  ]
}

# Because we probably don't want to tell people to come to
# "my-webapp.prod.example.com", we make a CNAME that points to that from
# the more user-friendly "my-webapp.example.com".
resource "aws_route53_record" "prod_my_webapp_alb" {
  zone_id = aws_route53_zone.example_com.zone_id
  name    = "my-webapp.example.com"
  type    = "CNAME"
  records = ["my-webapp.prod.example.com"]
  ttl     = 3600
}
