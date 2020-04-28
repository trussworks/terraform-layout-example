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
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cidr\_slash16 | First 2 octects of the /16 CIDR to use for the VPC. | string | n/a | yes |
| environment |  | string | n/a | yes |
| region |  | string | n/a | yes |
| single\_nat\_gateway | Whether to provision a single shared NAT Gateway across all the private networks. | string | `"false"` | no |

## Outputs

| Name | Description |
|------|-------------|
| private\_subnets | List of IDs of private subnets. |
| public\_subnets | List of IDs of public subnets. |
| vpc\_id | The ID of the VPC. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
