provider "aws" {
  version = "~> 3.0"
  region  = var.region
}

provider "template" {
  version = "~> 2.1"
}
