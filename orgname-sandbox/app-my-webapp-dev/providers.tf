provider "aws" {
  version = "~> 5.0"
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
