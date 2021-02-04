# terraform-layout-example

This repository is meant to serve as an example of how Truss builds out
repositories for Terraform deployments. We've taken care to add as much
documentation and code comments around *why* we do things the way they
are outlined here as possible, so that newcomers to these patterns can
gain some understanding of why we did things this way.

This repository is meant to be a living document -- if we change our
method of doing things, we should update this repository, and engineers
who have questions about why we do things that are not adequately
explained or who have suggestions for improvements should feel free to
file issues and/or PRs to improve the quality of the repo.

```text
.
├── bin
├── modules
├── orgname-org-root
│   ├── admin-global
│   └── bootstrap
└── orgname-id
│   ├── admin-global
│   └── bootstrap
└── orgname-infra
│   ├── admin-global
│   └── bootstrap
|   ├── <infra resource -- eg, atlantis>
└── orgname-<whatever>
    ├── admin-global
    └── bootstrap
    ├── <stack>-global
    └── <stack>-<environment>
```

## Top-Level

The following files are expected to be found:

* `README.md` — Should contain, at the very least, a configuration guide
  for accessing the necessary cloud services. For example, instructions
  on using `aws-vault` to configure your AWS credentials.
* `.envrc` — Global settings across accounts. E.g.,
  `AWS_VAULT_KEYCHAIN_NAME`, `CHAMBER_KMS_KEY_ALIAS`. See the [example
  .envrc file](.envrc).

## bin

```text
bin
├── aws -> aws-vault-wrapper
├── aws-vault-wrapper
├── chamber -> aws-vault-wrapper
├── packer -> aws-vault-wrapper
└── terraform -> aws-vault-wrapper
```

The `bin` directory typically contains an `aws-vault-wrapper` script with
symlinks for things like `aws`, `chamber`, `packer`, `terraform`, etc.
depending on the project's needs.

Additional tools and scripts needed for managing the infrastructure also go here.

## Modules

In general, we should avoid having modules in the Terraform repository
proper. We should make every effort to open source modules and add them
to the [Terraform Registry](https://registry.terraform.io) when we can;
if the modules are specific to a project, we should put them in another
repository and use them from there via the Git source method (see
[GitHub module sources](https://www.terraform.io/docs/modules/sources.html#github)
in the Terraform docs). See the [Modules directory README](modules/README.md)
for a more thorough explanation.


## AWS Organizations

Using AWS Organizations is highly recommended for all our projects. They
provide a way to handle consolidated billing, compartmentalization of
environments and permissions, and a variety of other advantages. For a
full discussion of how to set up an AWS Organization properly, see these
resources in the Truss Engineering Playbook:

* [AWS Organizations Patterns](https://github.com/trussworks/Engineering-Playbook/blob/master/infrasec/aws/aws-organizations.md)
* [AWS Organizations Bootstrap Guide](https://github.com/trussworks/Engineering-Playbook/blob/master/infrasec/aws/org-bootstrap.md)

## AWS Accounts

For each AWS account, we create a directory with the name of the account
alias.

The following files are expected to be found:

* `.envrc` — Account specific settings such as `AWS_PROFILE`. See the
  [example .envrc file](orgname-sandbox/.envrc).

### The bootstrap Directory

When initially creating Terraform infrastructure, we use the
[terraform-aws-bootstrap](https://github.com/trussworks/terraform-aws-bootstrap)
repository to create the resources needed to set up remote Terraform
state and locking via DynamoDB. If this is an organization we started
from scratch, this directory should exist (and if you are setting up
this infrastructure from scratch, you should follow this pattern and
the instructions in that repository to set up each account).

Once an account is bootstrapped, *this directory should not be touched
again* unless the account is being torn down. The directory will contain
the statefile for these resources, and therefore doing anything with
this namespace could break Terraform for the entire account.

No resources should be defined here aside from the two S3 buckets and
the DynamoDB table that the bootstrap script creates.

### admin-global

The `admin-global` namespace is intended to hold resources that are used
for overall account configuration. Resources defined here could include:

* AWS Organization configurations (org-root account only)
* Account level infrasec tools (eg, AWS Cloudtrail, AWS Config)
* Non-application-specific IAM users, policies and roles
* Non-stack-specific DNS configuration

### Stack Environments

```text
<stack>-<environment>
├── terraform.tf
├── providers.tf
├── main.tf
└── variables.tf
```

This is where the meat of the matter is. For each stack and environment
we create a directory with the name of the stack (or purpose) and
environment. We try to make these distinctive so that it is easy to tell
what is in each namespace at a glance.

A "stack" refers to a collection of resources serving a single purpose;
if the "my-webapp" application consists of a frontend application, an
API application, and a database, those three components make up a single
stack.

The `global` environment is used for resources that might be shared
between multiple individual environments. For instance, in this repo, the
`orgname-sandbox` account holds two environments - the `experimental`
environment and the `dev` environment. However, we decided we didn't need
individual VPCs for those environments, so the single sandbox VPC is
defined in the `app-my-webapp-global` namespace.

Other environments, like `experimental`, `dev`, or `prod`, contain all
the resources for that isolated instance of the stack. Individual stacks
should not interact with each other *except* through publically accessible
methods (eg, an API interface exposed via an ALB).

The following files are expected to be found:

* `terraform.tf` — Contains the `terraform {}` configuration block.
  This will set a minimum `terraform` version and configure the backend.
* `providers.tf` — Contains the `provider {}` blocks indicating the
  version of each provider needed.
* `main.tf` — The infrastructure code. As this file grows, consider
   breaking it up into smaller, well-named files. For example, a
   `circleci.tf` file could contain the IAM user, group, and policies
   needed for a CircleCI build to run.
* `variables.tf` — This almost always has, at minimum, a `region`
  and `environment` variable set.

#### A Note on Variables vs Locals

You'll notice that instead of defining variables for the root module
with `locals`, we define them in `variables.tf` with `variable` blocks.
We do this because if you use locals, you cannot do a `terraform
import`, which has caused us problems in the past. In addition, with
`variable` declarations, you can also define the type and description
for the variable, which can provide additional context for human users.
