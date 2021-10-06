terraform {
  required_version = "~> 1.0"

  backend "s3" {
    bucket         = "orgname-sandbox-terraform-state-us-west-2"
    key            = "app-my-webapp-global/terraform.tfstate"
    dynamodb_table = "terraform-state-lock"
    region         = "us-west-2"
    encrypt        = "true"
  }
}
