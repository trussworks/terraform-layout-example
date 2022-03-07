provider "aws" {
  version = "~> 4.0"
  region  = var.region
}

# This is a special provider we use for Route53, because that service
# only exists in us-east-1. Note that we call this specifically where
# we create DNS entries.
provider "aws" {
  version = "~> 4.0"
  alias   = "us-east-1"
  region  = "us-east-1"
}

provider "template" {
  version = "~> 2.1"
}
