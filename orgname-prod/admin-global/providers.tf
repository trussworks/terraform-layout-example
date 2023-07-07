provider "aws" {
  version = "~> 5.0"
  region  = var.region

  default_tags {
    tags = {
      Automation : "Terraform"
    }
  }
}

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
