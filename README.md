# terraform-layout-example

```text
.
├── bin
├── modules
├── aws-account-alias-root
│   ├── admin-global
│   └── bootstrap
└── <aws-account-alias>
    ├── bootstrap
    ├── admin-global
    ├── <stack>-global
    └── <stack>-<environment>
```

## top-level

The following files are expected to be found:

* `README.md` — Should contain, at the very least, a configuration guide for accessing the necessary cloud services. For example, instructions on using `aws-vault` to configure your AWS credentials.
* `.envrc` — Global settings across accounts. E.g., `AWS_VAULT_KEYCHAIN_NAME`, `CHAMBER_KMS_KEY_ALIAS`. See the [example .envrc file](.envrc).

## bin

```text
bin
├── aws -> aws-vault-wrapper
├── aws-vault-wrapper
├── chamber -> aws-vault-wrapper
├── packer -> aws-vault-wrapper
└── terraform -> aws-vault-wrapper
```

The `bin` directory typically contains an `aws-vault-wrapper` script with symlinks for things like `aws`, `chamber`, `packer`, `terraform`, etc. depending on the project's needs.

Additional tools and scripts needed for managing the infrastructure also go here.

## modules

We've open sourced a good deal of our modules and [registered them with the Terraform Module Registry](https://registry.terraform.io/modules/trussworks). In general, use modules from the registry instead of maintaining a local copy.

For new modules under development or modules specific to a project (i.e., they couldn't be useful outside of the project), place them in this top-level modules directory. They should be written to be reusable across accounts and environments.

## aws organizations and the root aws account

AWS Organizations provide a native way to manage multiple AWS accounts. They provide consolidated billing, APIs (e.g., via Terraform) for automating account creation, and the ability to apply account-wide IAM like policies. These configurations are manged in the root AWS account. No other AWS resources should be defined in the root account.

## aws account aliases

For each AWS account, we create a directory with the name of the account alias.

The following files are expected to be found:

* `.envrc` — Account specific settings such as `AWS_PROFILE`. See the [example .envrc file](aws-account-alias-one/.envrc).

### bootstrap (optional)

Inside each account directory there _may_ be a `bootstrap` directory. This is only needed if the AWS account doesn't already have a Terraform state bucket and locking table in place. E.g., a newly created account or an account that has never been managed with Terraform.

We populate this directly from our [terraform-aws-bootstrap](https://github.com/trussworks/terraform-aws-bootstrap) repository. It's used to create the resources needed to use Terraform with remote state and locking. This is the only directory where a `terraform.tfstate` file may live and be synchronized via git. Nothing besides these bootstrapped resources should be in here.

### stack environments

```text
<stack>-<environment>
├── terraform.tf
├── providers.tf
├── main.tf
└── variables.tf
```

This is where the meat of the matter is. For each stack and environment we create a directory with the name of the stack (or purpose) and environment.
There are a few special names we use here.

By "stack", we mean a collection of resources around a single purpose. Some examples:

* "packer" – may hold all the resources for running Packer builds: VPC, Security Groups, IAM roles/policies, etc.
* "myapp" - may hold all the resources for running the MyApp web app: VPC, ECS cluster and services, ECR repos, ALB, RDS, etc.

For administrative resources we always use the special name "admin". An example of this would be managing IAM users, roles, and policies for engineers and/or external services.

By "environment", we mean names like "prod", "staging", "lab", etc.

For resources that are global across environments we always use the special name "global". An example of this would be an ECR repository that dev, staging, and prod all pull from.

The following files are expected to be found:

* `terraform.tf` — Contains the `terraform {}` configuration block. This will set a minimum `terraform` version and configure the backend.
* `providers.tf` — Contains the `provider {}` blocks indicating the version of each provider needed.
* `main.tf` — The infrastructure code. As this file grows, consider breaking it up into smaller, well-named files. For example, a `circleci.tf` file could contain the IAM user, group, and policies needed for a CircleCI build to run.
* `variables.tf` — This almost always has, at minimum, a `region` variable set.
