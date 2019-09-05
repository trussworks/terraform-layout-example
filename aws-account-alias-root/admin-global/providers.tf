provider "aws" {
  version = "~> 2.26.0"
  region  = "${local.region}"
}

provider "template" {
  version = "~> 2.1.2"
}
