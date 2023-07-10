provider "aws" {
  version = "~> 5.0"
  region  = var.region

  default_tags {
    tags = {
      Automation : "Terraform"
    }
  }
}

# This is a special provider we use for Route53, because that service
# only exists in us-east-1. Note that we call this specifically where
# we create DNS entries.
provider "aws" {
  version = "~> 5.0"
  alias   = "us-east-1"
  region  = "us-east-1"

  default_tags {
    tags = {
      Automation : "Terraform"
    }
  }
}

provider "template" {
  version = "~> 2.1"
}
