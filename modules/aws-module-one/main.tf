/**
 * Creates a VPC in two availability zones (AZs) and locks down the default
 * Security Group automatically created by AWS.
 *
 * ## Usage
 *
 * ```hcl
 * module "app_vpc" {
 *   source = "../../modules/aws-app-vpc"
 *
 *   region             = "${var.region}"
 *   name               = "${var.name}"
 *   environment        = "${var.environment}"
 *   cidr_slash16       = "10.42"
 *   single_nat_gateway = true
 * }
 * ```
 */

#
# VPC
#

locals {
  vpc_name = "${var.name}-${var.environment}"
  vpc_cidr = "${var.cidr_slash16}.0.0/16"
}

# Region
# ------
# 0.0/16:
#   0.0/18 — AZ A
#   64.0/18 — AZ B
#   128.0/18 — [spare]
#   192.0/18 — [spare]
#
# AZ A
# ----
# 0.0/18
#   0.0/19 - Private
#   32.0/19
#     32.0/20 - Public
#     48.0/20 - [spare]
#
# AZ B
# ----
# 64.0/18
#   64.0/19 - Private
#   96.0/19
#     96.0/20 - Public
#     112.0/20 - [spare]
#

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 1.46.0"

  name = "${local.vpc_name}"
  cidr = "${local.vpc_cidr}"

  azs             = ["${var.region}a", "${var.region}b"]
  private_subnets = ["${cidrsubnet(local.vpc_cidr, 3, 0)}", "${cidrsubnet(local.vpc_cidr, 3, 2)}"]
  public_subnets  = ["${cidrsubnet(local.vpc_cidr, 4, 2)}", "${cidrsubnet(local.vpc_cidr, 4, 6)}"]

  enable_nat_gateway = true
  single_nat_gateway = "${var.single_nat_gateway}"
  enable_s3_endpoint = true

  # required when using private hosted zones
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = "${var.environment}"
    Automation  = "Terraform"
  }
}

# Remove the permissiveness of the default SG that's created by AWS.
resource "aws_default_security_group" "default" {
  vpc_id = "${module.vpc.vpc_id}"

  # We have to specify at least one rule, otherwise the default rules will
  # remain. We use ICMP Destination Unrechable as the dummy entry.
  ingress {
    description = "Dummy rule; need one"

    protocol  = 1    # ICMP
    from_port = 3    # Destination Unreachable
    to_port   = 0
    self      = true
  }

  tags = {
    Environment = "${var.environment}"
    Automation  = "Terraform"
  }
}
