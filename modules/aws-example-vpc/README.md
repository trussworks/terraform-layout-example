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
Error: Failed to read module directory: Module directory /var/folders/cv/5g741k8d2n53nt2c9rb7228w0000gn/T//terraform-docs-vGgXSjB7zl.tf does not exist or cannot be read.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
