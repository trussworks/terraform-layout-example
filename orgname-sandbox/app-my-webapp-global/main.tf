# Because we have two my-webapp environments in the sandbox account and
# we don't really need to make sure they are isolated on the network or
# using separate ECR repos, we are creating a single VPC and ECR repo
# for my-webapp to use for all sandbox deployments. This also makes it
# easy to stamp out another sandbox environment if we need it, even just
# temporarily (for instance, if we wanted an "infratest" environment).

#
# VPC
#

# For the cidr_slash16 here, we're using the 10.0.0.0/8 network bloc;
# this is a non-internet routable network bloc, so we can use it on
# our internal network safely, and since it's a /8 we can make lots of
# /16s inside it (256 to be exact), so it's a good one to use. You can
# read about these network address spaces here:
# https://en.wikipedia.org/wiki/Private_network
module "sandbox_vpc" {
  source = "../../modules/aws-example-vpc"

  region      = var.region
  environment = var.environment

  cidr_slash16 = "10.0"
}

module "app_my_webapp_sandbox_ecr" {
  source = "../../modules/aws-example-ecr-repo"

  name = "app-my-webapp"
}
