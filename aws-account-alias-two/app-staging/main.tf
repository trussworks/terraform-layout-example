locals {
  region = "us-west-2"
}

#
# VPC
#

module "app_vpc" {
  source = "../../modules/aws-app-vpc"

  region             = "${local.region}"
  environment        = "${var.environment}"
  cidr_slash16       = "${var.cidr_slash16}"
  single_nat_gateway = "${var.single_nat_gateway}"
}

#
# ECS Cluster
#

resource "aws_ecs_cluster" "main" {
  name = "${var.environment}"
}

#
# app
#

module "app" {
  source = "../../modules/aws-app"

  name        = "myapp"
  environment = "${var.environment}"

  vpc_id          = "${module.app_vpc.vpc_id}"
  private_subnets = "${module.app_vpc.private_subnets}"
  public_subnets  = "${module.app_vpc.public_subnets}"

  ecs_cluster_arn = "${aws_ecs_cluster.main.arn}"
}
