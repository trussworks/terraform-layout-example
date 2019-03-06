provider "aws" {
  version = "~> 1.60.0"
  region  = "${var.region}"
}

provider "template" {
  version = "~> 2.1.0"
}

provider "archive" {
  version = "~> 1.1.0"
}
