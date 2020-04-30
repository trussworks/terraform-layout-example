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
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cidr\_slash16 | First 2 octects of the /16 CIDR to use for the VPC. | `string` | n/a | yes |
| environment | Environment name | `string` | n/a | yes |
| region | AWS region | `string` | n/a | yes |
| single\_nat\_gateway | Whether to define a single NAT gateway for all AZs | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| database\_subnets | List of IDs of DB subnets. |
| nat\_eips | List of EIPs for NAT gateways. |
| private\_subnets | List of IDs of private subnets. |
| public\_subnets | List of IDs of public subnets. |
| vpc\_id | The ID of the VPC. |
| vpc\_name | The name of the VPC. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
