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

No output.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
