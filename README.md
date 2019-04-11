# terraform-layout-example

This is the basic approach Truss takes towards Terraform layout.

```
├── bin
├── modules
└── <aws-account-alias>
    ├── bootstrap
    ├── admin-global
    ├── <stack>-global
    └── <stack>-<environment>
```

## bin

The `bin` directory typically contains an `aws-vault-wrapper` script with symlinks for things like `aws`, `chamber`, `packer`, `terraform`, etc. depending on the project's needs.

## modules

The `modules` directory contains modules that are reusable across accounts. When appropriate, we'll open source the modules, move it to it's own repo, put it in the [Terraform Module Registry](http://registry.terraform.io/), and use it from there.

## aws account aliases

For each AWS account, we create a directory with the name of the account alias.

### bootstrap (optional)

Inside each account directory there may be a `bootstrap` directory. This is needed if the AWS account didn't already have a Terraform state bucket and locking table in place. E.g., a newly created account or an account that has never been managed with Terraform.

We populate this directly from our [terraform-aws-bootstrap](https://github.com/trussworks/terraform-aws-bootstrap) repository. It's used to create the resources needed to use Terraform with remote state and locking. This is the only directory where a `terraform.tfstate` file may live and be synchronized via git. Nothing besides these bootstrapped resources should be in here.

### stack environments

This is where the meat of the matter is. For each stack and environment we create a directory with the name of the stack or purpose and environment. There are a few special names that get used here.

By "stack", we mean a collection of resources around a single purpose. Some examples:

*  "packer" – may hold all the resources for running Packer builds: VPC, Security Groups, IAM roles/policies, etc.
*  "myapp" - may hold all the resources for running the MyApp web app: VPC, ECS cluster and services, ECR repos, ALB, RDS, etc.

For administrative resources we always use the special name "admin". An example of this would be managing IAM users, roles, and policies for engineers.

By "environment", we mean names like "prod", "staging", "lab", etc.

For resources that are global across environments we always use the special name "global". An example of this would be an ECR repository that dev, staging, and prod all pull from.
