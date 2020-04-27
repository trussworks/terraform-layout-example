terraform {
  required_version = "~> 0.12.24"

  backend "s3" {
    bucket         = "orgname-sandbox-terraform-state-us-west-2"
    key            = "app-my-webapp-dev/terraform.tfstate"
    dynamodb_table = "terraform-state-lock"
    region         = "us-west-2"
    encrypt        = "true"
  }
}
