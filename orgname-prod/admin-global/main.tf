locals {
  region                = "us-west-2"
  aws_logs_bucket_alias = "aws-account-alias-two-logs"
}

#
# ECS Service-Linked Role
#
resource "aws_iam_service_linked_role" "main" {
  aws_service_name = "ecs.amazonaws.com"
}

#
# AWS logging buckets
#
module "logs" {
  source  = "trussworks/logs/aws"
  version = "~>2.0.0"

  region         = "${local.region}"
  s3_bucket_name = "${local.aws_logs_bucket_alias}-${local.region}"
}
