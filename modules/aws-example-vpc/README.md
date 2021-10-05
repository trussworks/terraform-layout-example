Creates a VPC with two availability zones, two static EIPs for attaching
to the NAT gateways, and overrides the default security group with a dummy
rule that blocks all access.

## Usage

```hcl
module "app_vpc" {
  source = "../../modules/aws-example-vpc"

  region             = var.region
  environment        = var.environment
  cidr_slash16       = "10.42"
}
```

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
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 2.33.0 |

## Resources

| Name | Type |
|------|------|
| [aws_default_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidr_slash16"></a> [cidr\_slash16](#input\_cidr\_slash16) | First 2 octects of the /16 CIDR to use for the VPC. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | n/a | yes |
| <a name="input_single_nat_gateway"></a> [single\_nat\_gateway](#input\_single\_nat\_gateway) | Whether to define a single NAT gateway for all AZs | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database_subnets"></a> [database\_subnets](#output\_database\_subnets) | List of IDs of DB subnets. |
| <a name="output_nat_eips"></a> [nat\_eips](#output\_nat\_eips) | List of EIPs for NAT gateways. |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | List of IDs of private subnets. |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | List of IDs of public subnets. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC. |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | The name of the VPC. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
