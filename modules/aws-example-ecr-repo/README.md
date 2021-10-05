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
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecr_lifecycle_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_repository.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| lifecycle\_policy | ECR repository lifecycle policy document. Used to override our default policy. | `string` | `""` | no |
| name | ECR repository name. | `string` | n/a | yes |
| tags | Additional tags to apply. | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | Full ARN of the repository. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
