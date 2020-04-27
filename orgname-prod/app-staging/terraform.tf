terraform {
  required_version = "~> 0.11.11"

  backend "s3" {
    bucket         = "aws-account-alias-two-terraform-state-us-west-2"
    key            = "app-staging/terraform.tfstate"
    dynamodb_table = "terraform-state-lock"
    region         = "us-west-2"
    encrypt        = "true"
  }
}
