#
# ECR
#

module "ecr_ecs_myapp_base" {
  source = "../../modules/aws-ecr-repository"
  name   = "myapp-base"
}

module "ecr_ecs_myapp" {
  source = "../../modules/aws-ecr-repository"
  name   = "myapp"
}

#
# S3
#

# provisions an S3 bucket for storing data relevant to CI/CD processes
module "bucket_app_data" {
  source  = "trussworks/s3-private-bucket/aws"
  version = "~> 1.7.1"

  bucket         = "app-data"
  logging_bucket = "aws-account-alias-two-logs"

  tags {
    Automation = "Terraform"
  }
}
