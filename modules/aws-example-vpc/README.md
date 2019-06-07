<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
Creates a VPC in two availability zones (AZs) and locks down the default
Security Group automatically created by AWS.

## Usage

```hcl
module "app_vpc" {
  source = "../../modules/aws-app-vpc"

  region             = "${var.region}"
  name               = "${var.name}"
  environment        = "${var.environment}"
  cidr_slash16       = "10.42"
  single_nat_gateway = true
}
```

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
