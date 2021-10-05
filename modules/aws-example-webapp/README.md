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
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb_my_webapp"></a> [alb\_my\_webapp](#module\_alb\_my\_webapp) | trussworks/alb-web-containers/aws | ~> 3.0.2 |
| <a name="module_ecs_service_my_webapp"></a> [ecs\_service\_my\_webapp](#module\_ecs\_service\_my\_webapp) | trussworks/ecs-service/aws | ~> 3.0.0 |
| <a name="module_my_webapp_db"></a> [my\_webapp\_db](#module\_my\_webapp\_db) | terraform-aws-modules/rds/aws | ~> 2.14 |

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
| <a name="input_alb_health_check_interval"></a> [alb\_health\_check\_interval](#input\_alb\_health\_check\_interval) | Interval for ALB health check (in seconds) | `number` | `30` | no |
| <a name="input_alb_health_check_path"></a> [alb\_health\_check\_path](#input\_alb\_health\_check\_path) | Path for ALB health check | `string` | `"/health"` | no |
| <a name="input_alb_health_check_timeout"></a> [alb\_health\_check\_timeout](#input\_alb\_health\_check\_timeout) | Timeout for ALB health check (in seconds) | `number` | `5` | no |
| <a name="input_alb_logs_bucket"></a> [alb\_logs\_bucket](#input\_alb\_logs\_bucket) | S3 bucket for ALB logs | `string` | n/a | yes |
| <a name="input_alb_subnets"></a> [alb\_subnets](#input\_alb\_subnets) | Subnets for ALB | `list(string)` | n/a | yes |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | Port for container listener | `number` | `8080` | no |
| <a name="input_db_allocated_storage"></a> [db\_allocated\_storage](#input\_db\_allocated\_storage) | Allocated storage for RDS instance (in GB) | `number` | `20` | no |
| <a name="input_db_backup_retention"></a> [db\_backup\_retention](#input\_db\_backup\_retention) | RDS backup retention (in days) | `number` | `7` | no |
| <a name="input_db_instance_class"></a> [db\_instance\_class](#input\_db\_instance\_class) | Instance class for RDS instance | `string` | `"db.t3.small"` | no |
| <a name="input_db_multi_az"></a> [db\_multi\_az](#input\_db\_multi\_az) | Multi AZ setting for RDS | `bool` | `false` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Name for database on RDS instance | `string` | `"my_webapp"` | no |
| <a name="input_db_subnet_group_name"></a> [db\_subnet\_group\_name](#input\_db\_subnet\_group\_name) | DB subnet group name | `string` | n/a | yes |
| <a name="input_db_subnets"></a> [db\_subnets](#input\_db\_subnets) | List of DB subnets | `list(string)` | n/a | yes |
| <a name="input_db_user"></a> [db\_user](#input\_db\_user) | User for accessing RDS instance | `string` | `"master"` | no |
| <a name="input_dns_zone_id"></a> [dns\_zone\_id](#input\_dns\_zone\_id) | Zone ID for DNS | `string` | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Outward facing FQDN for service | `string` | n/a | yes |
| <a name="input_ecs_subnets"></a> [ecs\_subnets](#input\_ecs\_subnets) | Subnets for ECS service | `list(string)` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment | `string` | n/a | yes |
| <a name="input_final_snapshot_identifier"></a> [final\_snapshot\_identifier](#input\_final\_snapshot\_identifier) | Final RDS snapshot identifier | `string` | `""` | no |
| <a name="input_pg_family"></a> [pg\_family](#input\_pg\_family) | DB parameter family for RDS instance | `string` | `"postgres12"` | no |
| <a name="input_pg_version"></a> [pg\_version](#input\_pg\_version) | PostgreSQL version for the RDS instance | `string` | `"12.2"` | no |
| <a name="input_tasks_desired_count"></a> [tasks\_desired\_count](#input\_tasks\_desired\_count) | Number of ECS tasks to run | `number` | `1` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
