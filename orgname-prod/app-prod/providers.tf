provider "aws" {
  version = "~> 1.60.0"
  region  = "${local.region}"
}

provider "archive" {
  version = "~> 1.1.0"
}

provider "null" {
  version = "~> 1.0.0"
}

provider "template" {
  version = "~> 2.1.0"
}
