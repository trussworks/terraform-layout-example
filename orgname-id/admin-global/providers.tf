provider "aws" {
  version = "~> 5.0"
  region  = var.region
}

provider "template" {
  version = "~> 2.1"
}
