terraform {
  required_version = "~> 0.11.11"

  backend "s3" {
    bucket         = "aws-account-alias-one-terraform-state-us-west-2"
    key            = "admin-global/terraform.tfstate"
    dynamodb_table = "terraform-state-lock"
    region         = "us-west-2"
    encrypt        = "true"
  }
}
