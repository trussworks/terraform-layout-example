# Modules

One of the real advantages of Terraform is being able to create modules
-- reusable Terraform components we can use in multiple namespaces. In
practice, for projects you're working on, you will probably want to use
modules which are either public and in the [Terraform
Registry](https://registry.terraform.io) or in separate Git repositories
within your project -- you should avoid putting modules in a directory
like this one most of the time. We've just included these as an example
of modules you might create for a project.

Why should you put modules in separate repositories? There's two big
reasons to do this. The first is that putting them in a separate repo
allows you to specify versions of the module (via version numbers or
Git SHAs) in individual environments, so that you can say, update the
version of the module that deploys `my-webapp` in the `dev` environment
but *not* in the `prod` environment until it has been thoroughly tested.

Second, placing them in a separate repo within your GitHub organization
allows you to use that module easily in another Terraform repository for
your project. This is becoming more important as we look at projects that
have a requirement for using GovCloud, where we recommend keeping the
Terraform configuration for that separate from commercial AWS deployments.
