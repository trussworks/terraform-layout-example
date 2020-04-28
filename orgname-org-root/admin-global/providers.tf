provider "aws" {
  version = "~> 2.59"
  region  = var.region
}

provider "template" {
  version = "~> 2.1"
}
