provider "aws" {
  version = "~> 4.0"
  region  = var.region
}

provider "template" {
  version = "~> 2.1"
}
