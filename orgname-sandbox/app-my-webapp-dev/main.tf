#
# VPC
#

# We need to create a data source to get information about the DNS zone
# we're using for the webapp module to create DNS entries.
data "aws_route53_zone" "sandbox" {
  name = var.zone_name
}

# For the cidr_slash16 here, we're using the 10.0.0.0/8 network bloc;
# this is a non-internet routable network bloc, so we can use it on
# our internal network safely, and since it's a /8 we can make lots of
# /16s inside it (256 to be exact), so it's a good one to use. You can
# read about these network address spaces here:
# https://en.wikipedia.org/wiki/Private_network
module "dev_vpc" {
  source = "../../modules/aws-example-vpc"

  region      = var.region
  environment = var.environment

  cidr_slash16 = "10.0"
}

module "app_my_webapp_dev_ecr" {
  source = "../../modules/aws-example-ecr-repo"

  name = "app-my-webapp"
}

module "my_webapp_dev" {
  source = "../../modules/aws-example-webapp"

  alb_logs_bucket = var.logging_bucket
  alb_subnets     = module.dev_vpc.public_subnets

  db_subnet_group_name = module.dev_vpc.vpc_name
  db_subnets           = module.dev_vpc.database_subnets

  dns_zone_id = data.aws_route53_zone.sandbox.zone_id
  domain_name = "my-webapp.dev.sandbox.example.com"
  
  ecs_subnets = module.dev_vpc.private_subnets
  environment = var.environment

  vpc_id = module.dev_vpc.vpc_id
}
