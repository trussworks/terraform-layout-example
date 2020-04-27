provider "aws" {
  version = "~> 2.58"
  region  = var.region
}

provider "template" {
  version = "~> 2.1.2"
}
