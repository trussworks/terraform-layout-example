Creates an ECR repo and lifeycle policy. Defaults to our standard lifecycle
policy if one is not supplied.

Creates the following resources:

* ECR repository
* ECR repository lifecycle

## Usage

```hcl
module "ecr_ecs_myapp" {
 source = "../../modules/aws-example-ecr-repo"
 name   = "my-webapp"
 tags   = {
   Application = "my-webapp"
 }
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
Error: Failed to read module directory: Module directory /var/folders/cv/5g741k8d2n53nt2c9rb7228w0000gn/T//terraform-docs-1fdHRBb3fE.tf does not exist or cannot be read.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
