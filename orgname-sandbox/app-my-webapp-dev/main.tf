#
# VPC
#

# We need to create a data source to get information about the DNS zone
# we're using for the webapp module to create DNS entries.
data "aws_route53_zone" "sandbox" {
  name = var.zone_name
}

# We've already created the VPC in the "app-my-webapp-global" namespace,
# so we don't need to make it here, but we do need to import it as a
# data source so we can get the various subnets to plug into our
# application modules.
data "aws_vpc" "sandbox_vpc" {
  name = "vpc-sandbox"
}

# We also have to import all the subnets we're using individually because
# of the way the terraform-aws-vpc module works. Note that these data sources
# return a list of ids (even though they will only match a single one, so
# when we use them later, we need to use flatten to combine them.

data "aws_subnet_ids" "public_1" {
  vpc_id = data.aws_vpc.sandbox_vpc.id

  tags = {
    Name = format("vpc-sandbox-public-%sa", var.region)
  }
}

data "aws_subnet_ids" "public_2" {
  vpc_id = data.aws_vpc.sandbox_vpc.id

  tags = {
    Name = format("vpc-sandbox-public-%sb", var.region)
  }
}

data "aws_subnet_ids" "private_1" {
  vpc_id = data.aws_vpc.sandbox_vpc.id

  tags = {
    Name = format("vpc-sandbox-private-%sa", var.region)
  }
}

data "aws_subnet_ids" "private_2" {
  vpc_id = data.aws_vpc.sandbox_vpc.id

  tags = {
    Name = format("vpc-sandbox-private-%sb", var.region)
  }
}

data "aws_subnet_ids" "database_1" {
  vpc_id = data.aws_vpc.sandbox_vpc.id

  tags = {
    Name = format("vpc-sandbox-db-%sa", var.region)
  }
}

data "aws_subnet_ids" "database_2" {
  vpc_id = data.aws_vpc.sandbox_vpc.id

  tags = {
    Name = format("vpc-sandbox-db-%sb", var.region)
  }
}

# Now we call our module to deploy a stack of the my-webapp application.
# Most of these we just use the defaults, so we're just adding the ones
# that are required.
module "my_webapp_dev" {
  source = "../../modules/aws-example-webapp"

  alb_logs_bucket = var.logging_bucket
  alb_subnets     = flatten([data.aws_subnet_ids.public_1.ids, data.aws_subnet_ids.public_2.ids])

  db_subnet_group_name = module.dev_vpc.vpc_name
  db_subnets           = flatten([data.aws_subnet_ids.database_1.ids, data.aws_subnet_ids.database_2.ids])

  dns_zone_id = data.aws_route53_zone.sandbox.zone_id
  domain_name = "my-webapp.dev.sandbox.example.com"

  ecs_subnets = flatten([data.aws_subnet_ids.private_1.ids, data.aws_subnet_ids.private_2.ids])
  environment = var.environment

  vpc_id = data.aws_vpc.sandbox_vpc.id
}
