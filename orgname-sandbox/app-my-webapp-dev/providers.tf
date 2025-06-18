provider "aws" {
  version = "~> 6.0"
  region  = var.region

  default_tags {
    tags = {
      Automation : "Terraform"
    }
  }
}

provider "template" {
  version = "~> 2.1"
}
