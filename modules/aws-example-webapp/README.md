This module creates the set of resources necessary to stand up a stack
for the `my-webapp` application, including:

* ALB with Route53 DNS record and ACM certificate
* ECS cluster
* ECS service
* RDS instance

```hcl
module "app_my_webapp_dev" {
  source = "../../modules/aws-example-webapp

  alb_logs_bucket = var.logging_bucket
  alb_subnets     = module.my_webapp_vpc.public_subnets

  db_subnet_group_name = module.my_webapp_vpc.vpc_name
  db_subnets           = module.my_webapp_vpc.database_subnets

  dns_zone_id = data.aws_route53_zone.dev_zone.zone_id
  domain_name = "my-webapp.dev.example.com"

  ecs_subnets = module.my_webapp_vpc.private_subnets
  environment = "dev"

  vpc_id = module.my_webapp_vpc.vpc_id
}

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| alb\_my\_webapp | trussworks/alb-web-containers/aws | ~> 6.2.0 |
| ecs\_service\_my\_webapp | trussworks/ecs-service/aws | ~> 6.5.0 |
| my\_webapp\_db | terraform-aws-modules/rds/aws | ~> 3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.acm_my_webapp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_ecs_cluster.app_my_webapp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_iam_role_policy.task_role_policy_my_webapp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_kms_key.ecs_logs_my_webapp_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_route53_record.acm_my_webapp_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.my_webapp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.rds_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.rds_allow_ecs_app_inbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ssm_parameter.database_host](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.database_name](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.database_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ecr_repository.app_my_webapp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_repository) | data source |
| [aws_iam_policy_document.cloudwatch_logs_allow_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.task_role_policy_doc_my_webapp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_kms_alias.kms_ssm_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_alias) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_ssm_parameter.database_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| alb\_health\_check\_interval | Interval for ALB health check (in seconds) | `number` | `30` | no |
| alb\_health\_check\_path | Path for ALB health check | `string` | `"/health"` | no |
| alb\_health\_check\_timeout | Timeout for ALB health check (in seconds) | `number` | `5` | no |
| alb\_logs\_bucket | S3 bucket for ALB logs | `string` | n/a | yes |
| alb\_subnets | Subnets for ALB | `list(string)` | n/a | yes |
| container\_port | Port for container listener | `number` | `8080` | no |
| db\_allocated\_storage | Allocated storage for RDS instance (in GB) | `number` | `20` | no |
| db\_backup\_retention | RDS backup retention (in days) | `number` | `7` | no |
| db\_instance\_class | Instance class for RDS instance | `string` | `"db.t3.small"` | no |
| db\_multi\_az | Multi AZ setting for RDS | `bool` | `false` | no |
| db\_name | Name for database on RDS instance | `string` | `"my_webapp"` | no |
| db\_subnet\_group\_name | DB subnet group name | `string` | n/a | yes |
| db\_subnets | List of DB subnets | `list(string)` | n/a | yes |
| db\_user | User for accessing RDS instance | `string` | `"master"` | no |
| dns\_zone\_id | Zone ID for DNS | `string` | n/a | yes |
| domain\_name | Outward facing FQDN for service | `string` | n/a | yes |
| ecs\_subnets | Subnets for ECS service | `list(string)` | n/a | yes |
| environment | Environment | `string` | n/a | yes |
| final\_snapshot\_identifier | Final RDS snapshot identifier | `string` | `""` | no |
| pg\_family | DB parameter family for RDS instance | `string` | `"postgres12"` | no |
| pg\_version | PostgreSQL version for the RDS instance | `string` | `"12.2"` | no |
| tasks\_desired\_count | Number of ECS tasks to run | `number` | `1` | no |
| vpc\_id | VPC ID | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
