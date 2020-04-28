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
Error: Failed to read module directory: Module directory /var/folders/cv/5g741k8d2n53nt2c9rb7228w0000gn/T//terraform-docs-8mQesLQWmF.tf does not exist or cannot be read.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
