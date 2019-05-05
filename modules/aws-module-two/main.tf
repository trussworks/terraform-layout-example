/**
 * Creates an ECR repo and lifeycle policy. Defaults to our standard lifecycle
 * policy if one is not supplied.
 *
 * Creates the following resources:
 *
 * * ECR repository
 * * ECR repository lifecycle
 *
 * ## Usage
 *
 * ```hcl
 * module "ecr_ecs_myapp" {
 *  source = "../../modules/aws-ecr-repository"
 *  name   = "myapp"
 * }
 * ```
 */

locals {
  # Use our standard lifecycle policy if none passed in.
  policy = "${var.lifecycle_policy == "" ? file("${path.module}/lifecycle-policy.json") : var.lifecycle_policy}"

  tags = {
    Automation = "Terraform"
  }
}

resource "aws_ecr_repository" "main" {
  name = "${var.name}"
  tags = "${merge(local.tags, var.tags)}"
}

resource "aws_ecr_lifecycle_policy" "main" {
  repository = "${aws_ecr_repository.main.name}"
  policy     = "${local.policy}"
}
