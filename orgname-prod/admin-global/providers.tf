provider "aws" {
  version = "~> 5.0"
  region  = var.region
}

provider "aws" {
  version = "~> 5.0"
  alias   = "us-east-1"
  region  = "us-east-1"
}

provider "template" {
  version = "~> 2.1"
}
