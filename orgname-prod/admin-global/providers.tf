provider "aws" {
  version = "~> 2.59"
  region  = var.region
}

provider "aws" {
  version = "~> 2.59"
  alias   = "us-east-1"
  region  = "us-east-1"
}

provider "template" {
  version = "~> 2.1"
}
