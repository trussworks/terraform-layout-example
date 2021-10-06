# These data sources provide information about the environment this
# terraform is running in -- it's how we can know which account, region,
# and partition (ie, commercial AWS vs GovCloud) we're in.

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

# This creates a certificate via AWS Certificate Manager that we can
# use with the load balancer for our application, and the DNS record
# that we use to validate that we actually own the domain.

resource "aws_acm_certificate" "acm_my_webapp" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = {
    Name        = var.domain_name
    Environment = var.environment
    Automation  = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "acm_my_webapp_validation" {
  zone_id = var.dns_zone_id
  name    = aws_acm_certificate.acm_my_webapp.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.acm_my_webapp.domain_validation_options[0].resource_record_type
  records = [aws_acm_certificate.acm_my_webapp.domain_validation_options[0].resource_record_value]
  ttl     = 60
}

# Every application that we want to expose to the internet somehow
# is going to need some sort of load balancer. This lets us abstract
# the interface between the user and the containers running the actual
# application.
#
# In this case, we're using a Application Load Balancer (ALB), which
# is a layer 7 load balancer, which means it operates on HTTP; AWS also
# offers Network Load Balancers (NLB) which operate on layer 4, which
# means it operates on TCP. NLBs are used less commonly now, but are
# used in cases where the traffic is not HTTP or where the container
# needs to terminate SSL, such as when we're using client-cert auth.

module "alb_my_webapp" {
  source  = "trussworks/alb-web-containers/aws"
  version = "~> 6.2.0"

  name           = "my-webapp"
  environment    = var.environment
  logs_s3_bucket = var.alb_logs_bucket

  # The SSL policy here describes which protocols and ciphers can be used
  # to connect to the ALB. You can see a full description of these policies
  # here:
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html#describe-ssl-policies
  alb_ssl_policy              = "ELBSecurityPolicy-TLS-1-2-2017-01"
  alb_default_certificate_arn = aws_acm_certificate.acm_my_webapp.arn
  alb_certificate_arns        = []
  alb_vpc_id                  = var.vpc_id
  alb_subnet_ids              = var.alb_subnets

  # Note that for the container protocol here we're specifying HTTP,
  # which means the connection between the ALB and the container will
  # be unencrypted. This is done here for simplicity's sake; in a real
  # world implementation, we would make this HTTPS and give the container
  # a self-signed certificate so that the connection between the
  # containers and the ALB would *also* be encrypted.
  container_protocol = "HTTP"
  container_port     = var.container_port

  health_check_path     = var.alb_health_check_path
  health_check_interval = var.alb_health_check_interval
  health_check_timeout  = var.alb_health_check_timeout

  target_group_name = format("my-webapp-%s-%s", var.environment, var.container_port)

  allow_public_https = true
  allow_public_http  = true
}

# The ALB module will generate an ALB with a patterned DNS name -- something
# like "my-webapp-dev-12345678.us-west-2.elb.amazonaws.com". This name will
# also get regenerated if we rebuild the ALB for some reason, so if we can,
# we should make a DNS alias for this ALB that is something more intelligible.
resource "aws_route53_record" "my_webapp" {
  name    = var.domain_name
  zone_id = var.dns_zone_id
  type    = "A"

  alias {
    name                   = module.alb_my_webapp.alb_dns_name
    zone_id                = module.alb_my_webapp.alb_zone_id
    evaluate_target_health = false
  }
}

# We want to use a KMS key to encrypt our Cloudwatch logs for this
# service; this keeps the logs encrypted at rest on disk. As a rule, we
# always want to use encryption like this where we can.
#
# This sets up a policy that lets Cloudwatch logs actually use our KMS
# keys and then creates a key to use for encrypting these logs.

data "aws_iam_policy_document" "cloudwatch_logs_allow_kms" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      ]
    }

    actions = [
      "kms:*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "Allow logs KMS access"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
    }

    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["*"]
  }
}

resource "aws_kms_key" "ecs_logs_my_webapp_key" {
  description         = "Key for my-webapp ECS log encryption"
  enable_key_rotation = true

  policy = data.aws_iam_policy_document.cloudwatch_logs_allow_kms.json
}

# This data source pulls in the ECR repo for this application so we can
# use the docker containers stored there. This is created with the
# aws-example-ecr-repo in the overall namespace.
data "aws_ecr_repository" "app_my_webapp" {
  name = "app-my-webapp"
}

# We need to set up an ECS cluster to run the application in; if this is
# the only application we're running, then we can define the ECS cluster
# here; if we were running multiple applications in the same environment,
# we might want to define the cluster outside this module and then take
# it as a parameter instead.

resource "aws_ecs_cluster" "app_my_webapp" {
  name = format("app-my-webapp-%s", var.environment)

  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  tags = {
    Environment = var.environment
    Automation  = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# This is where we're actually defining the Fargate service for this
# application. The Truss module will seed the task definition for this
# service with a placeholder helloworld application; we use the CI/CD
# pipeline to replace that later with the real task definition.

module "ecs_service_my_webapp" {
  source  = "trussworks/ecs-service/aws"
  version = "~> 6.5.0"

  name        = "my-webapp"
  environment = var.environment

  logs_cloudwatch_retention     = var.cloudwatch_logs_retention_days
  logs_cloudwatch_group         = format("ecs-tasks-my-webapp-%s", var.environment)
  ecr_repo_arns                 = [data.aws_ecr_repository.app_my_webapp.arn]
  ecs_cluster                   = aws_ecs_cluster.app_my_webapp
  ecs_subnet_ids                = var.ecs_subnets
  ecs_use_fargate               = true
  ecs_vpc_id                    = var.vpc_id
  tasks_desired_count           = var.tasks_desired_count
  tasks_minimum_healthy_percent = 100
  tasks_maximum_percent         = 200

  target_groups = [
    {
      container_port             = var.container_port
      container_healthcheck_port = var.container_port
      lb_target_group_arn        = module.alb_my_webapp.alb_arn
    }
  ]

  alb_security_group = module.alb_my_webapp.alb_security_group_id
  kms_key_id         = aws_kms_key.ecs_logs_my_webapp_key.arn
}

# KMS Key used by AWS Parameter Store
data "aws_kms_alias" "kms_ssm_key" {
  name = "alias/aws/ssm"
}

# This policy for the ECS task role lets it access the AWS Parameter
# Store. This isn't strictly necessary, but it's a common pattern at
# Truss to store environment variables for applications in the Parameter
# Store and retrieve them at runtime with chamber, so this is something
# we'll see often.

data "aws_iam_policy_document" "task_role_policy_doc_my_webapp" {

  statement {
    actions = [
      "ssm:DescribeParameters"
    ]
    resources = [
      "*"
    ]
  }

  # Allow access to the environment specific app secrets
  statement {
    actions = [
      "ssm:GetParametersByPath"
    ]
    resources = [
      format("arn:aws:ssm:*:*:parameter/my-webapp-%s/*", var.environment)
    ]
  }

  # Allow decryption of Parameter Store values
  statement {
    actions = [
      "kms:ListKeys",
      "kms:ListAliases",
      "kms:Describe*",
      "kms:Decrypt",
    ]

    resources = [
      "${data.aws_kms_alias.kms_ssm_key.target_key_arn}"
    ]
  }
}

resource "aws_iam_role_policy" "task_role_policy_my_webapp" {
  name   = format("%s-policy", module.ecs_service_my_webapp.task_role_name)
  role   = module.ecs_service_my_webapp.task_role_name
  policy = data.aws_iam_policy_document.task_role_policy_doc_my_webapp.json
}
