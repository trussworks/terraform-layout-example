# Modules

One of the real advantages of Terraform is being able to create modules
-- reusable Terraform components we can use in multiple namespaces. In
practice, for projects you're working on, you will probably want to use
modules which are either public and in the [Terraform
Registry](https://registry.terraform.io) or in separate Git repositories
within your project -- you should avoid putting modules in a directory
like this one most of the time. We've just included these as an example
of modules you might create for a project.
