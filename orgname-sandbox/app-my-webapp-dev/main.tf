#
# VPC
#

# We need to create a data source to get information about the DNS zone
# we're using for the webapp module to create DNS entries.
data "aws_route53_zone" "sandbox" {
  name = var.zone_name
}

module "dev_vpc" {
  source = "../../modules/aws-example-vpc"

  region      = var.region
  environment = var.environment

  cidr_slash16 = "192.168"
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
