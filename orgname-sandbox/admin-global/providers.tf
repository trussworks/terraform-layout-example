provider "aws" {
  version = "~> 2.58"
  region  = var.region
}

provider "aws" {
  version = "~> 2.58"
  alias   = "us-east-1"
  region  = "us-east-1"
}

provider "template" {
  version = "~> 2.1.0"
}
