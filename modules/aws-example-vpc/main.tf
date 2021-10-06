locals {
  vpc_name = format("vpc-%s", var.environment)
  vpc_cidr = format("%s.0.0/16", var.cidr_slash16)
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

# By default, the VPC module creates EIPs for the NAT gateways that it
# will use ephemerally; so if we make changes to the VPC, it can tear
# down those EIPs and recreate them, changing the EIPs. However, we can
# create those separately and then pass them to the VPC module instead,
# and then changes to the VPC will not affect the NAT gateways.
#
# Why do this? Some clients will be interfacing with external partners
# that need to whitelist things by IP; if this is getting changed, we
# have to jump through hoops with these partners to update their
# firewalls. Creating these EIPs separately saves us from needing to
# do this.

resource "aws_eip" "nat" {
  count = var.single_nat_gateway ? 1 : 2
  vpc   = true

  tags = {
    Name        = format("nat-%s-%d", var.environment, count.index + 1)
    Environment = var.environment
    Automation  = "Terraform"
  }

  lifecycle {
    prevent_destroy = true
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.7.0"

  name = local.vpc_name
  cidr = local.vpc_cidr

  azs             = formatlist(format("%s%%s", var.region), ["a", "b"])
  private_subnets = ["${cidrsubnet(local.vpc_cidr, 3, 0)}", "${cidrsubnet(local.vpc_cidr, 3, 2)}"]
  public_subnets  = ["${cidrsubnet(local.vpc_cidr, 4, 2)}", "${cidrsubnet(local.vpc_cidr, 4, 6)}"]

  enable_nat_gateway = true
  single_nat_gateway = var.single_nat_gateway
  reuse_nat_ips      = true
  external_nat_ips   = aws_eip.nat.*.id

  enable_s3_endpoint = true

  tags = {
    Environment = var.environment
    Automation  = "Terraform"
  }
}

# Remove the permissiveness of the default SG that's created by AWS.
resource "aws_default_security_group" "default" {
  vpc_id = module.vpc.vpc_id

  # We have to specify at least one rule, otherwise the default rules will
  # remain. We use ICMP Destination Unreachable as the dummy entry.
  ingress {
    description = "Dummy rule; need one"

    protocol  = 1 # ICMP
    from_port = 3 # Destination Unreachable
    to_port   = 0
    self      = true
  }

  tags = {
    Environment = var.environment
    Automation  = "Terraform"
  }
}
