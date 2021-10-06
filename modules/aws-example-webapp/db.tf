# This file has configuration components for an RDS database instance
# for our sample webapp. We've separated them into this file to make it
# a little more clear how these components work. This example *is*
# PostgreSQL specific, but you can use a similar pattern with other
# RDS database types.

# It's pretty common for us to use T2 or T3 instances to run our RDS
# instances on; these are burstable CPU type instances which are
# especially useful for databases that tend to have uneven loads with
# high spikes when doing singular, high-impact transactions. If we are
# using these, we want to be able to set alarms based on whether we're
# eating into our CPU credit reserve, so we add some local variables to
# keep track of the per-instance maximums. You can find the source for
# these variables here: https://aws.amazon.com/rds/instance-types/

locals {
  cpu_credits_max = {
    "db.t2.small"   = 288
    "db.t2.medium"  = 576
    "db.t2.large"   = 864
    "db.t2.xlarge"  = 1296
    "db.t2.2xlarge" = 1944
    "db.t3.small"   = 576
    "db.t3.medium"  = 576
    "db.t3.large"   = 864
    "db.t3.xlarge"  = 2304
    "db.t3.2xlarge" = 4608
  }
}

#
# Security Group
#

# Here we're going to create a security group that will lock down the
# RDS instance so that it can only talk to the containers running our
# service. We do this by only allowing things that are in the security
# group we created with the my-webapp ECS service module to talk to the
# database. This is better than trying to lock down to a specific VPC
# or subnet in the vast majority of cases.

# In general, we don't want anyone talking to the database *except* in
# programmatic ways -- ie, through the web service sitting in front of it
# or via a one-off migration container running from the same security
# group.

resource "aws_security_group" "rds_sg" {
  name        = format("rds-my-webapp-%s", var.environment)
  description = format("my-webapp-%s RDS security group", var.environment)
  vpc_id      = var.vpc_id

  tags = {
    Name        = format("rds-my-webapp-%s", var.environment)
    Automation  = "Terraform"
    Environment = var.environment
  }
}

resource "aws_security_group_rule" "rds_allow_ecs_app_inbound" {
  description       = "Allow in my-webapp tasks"
  security_group_id = aws_security_group.rds_sg.id

  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = module.ecs_service_my_webapp.ecs_security_group_id
}

#
# RDS Connection SSM Parameters
#

# Here's one of the ways we can take advantage of the IAM policy we made in the
# main.tf to allow the ECS task to read parameters from SSM. We can define the
# connection settings for the database in SSM, and then use let the ECS task
# retrieve them there. Note the formatting of the parameter name; this is to
# align with the expectations of chamber (and make it easy to know what the
# parameters are for).

# For the database name and user, these aren't really "secrets" per se, so we
# can just take them as a variable and store them in code.

resource "aws_ssm_parameter" "database_name" {
  name        = format("/app-my-webapp-%s/database-name", var.environment)
  description = "Database name for my-webapp"
  type        = "SecureString"
  value       = var.db_name
}

resource "aws_ssm_parameter" "database_user" {
  name        = format("/app-my-webapp-%s/database-user", var.environment)
  description = "Database user for my-webapp"
  type        = "SecureString"
  value       = var.db_user
}

# For the password, we *don't* want to store this in code! So instead, we
# add it as a data source. Then we can add it to AWS via chamber (or the
# AWS CLI) and retrieve it for our use.
data "aws_ssm_parameter" "database_password" {
  name = format("/app-my-webapp-%s/database-password", var.environment)
}

# For the database host, this is a little trickier -- we actually have to
# wait for the database to be created, then get the DNS for the RDS
# instance and plug it into SSM. This comes from the RDS module we use
# just a bit further down in this file.
resource "aws_ssm_parameter" "database_host" {
  name        = format("/app-my-webapp-%s/database-host", var.environment)
  description = "Database host for my-webapp"
  type        = "SecureString"
  value       = module.my_webapp_db.this_db_instance_endpoint
}

#
# RDS Instance
#

module "my_webapp_db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 3.0"

  identifier = format("my-webapp-%s", var.environment)

  engine         = "postgres"
  engine_version = var.pg_version

  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  storage_encrypted = true
  multi_az          = var.db_multi_az

  # You may be asking why we're referring to the SSM parameters here
  # rather than the module parameters that those are derived from. This
  # is because we want to pull these parameters from the same place the
  # application is getting them, if for some reason that gets out of
  # sync. This *should* just be the same thing, but just in case...
  name     = aws_ssm_parameter.database_name.value
  username = aws_ssm_parameter.database_user.value
  password = data.aws_ssm_parameter.database_password.value
  port     = 5432

  # In order to handle some changes, you will temporarily need to set the
  # apply_immediately parameter to true. Set it back to false after you
  # have finished the change. Known cases:
  # - Major version upgrade
  # - Enable IAM DB authentication
  # - Storage resize
  # - Single AZ to multi AZ
  apply_immediately = false

  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = false

  # These times are UTC.
  maintenance_window = "Sun:06:00-Sun:09:00"
  backup_window      = "09:00-12:00"

  backup_retention_period = var.db_backup_retention

  tags = {
    Automation  = "Terraform"
    Environment = var.environment
  }

  create_db_option_group = false

  iam_database_authentication_enabled = false

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  # Generally we don't want to create a new DB subnet group because we
  # create one when we create the VPC in the first place. This means we
  # need to add the db_subnet_group_name explicitly when we call the
  # module for my-webapp. This should just be the same as your VPC name
  # usually, but we'll allow this to be individually configurable in
  # case for some reason we want to configure this separately.
  create_db_subnet_group = false
  db_subnet_group_name   = var.db_subnet_group_name

  # This is where we need to pass in the actual list of database subnets
  # in our VPC.
  subnet_ids = var.db_subnets

  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  # This is the name of the final snapshot taken when we delete the RDS
  # instance.
  final_snapshot_identifier = var.final_snapshot_identifier

  # Parameters for postgres (equivalent to postgresql.conf). Family is
  # the set of parameters you're using.
  family = var.pg_family

  parameters = [
    {
      # Require SSL for all connections. Note that this will require some
      # configuration on your application to make sure the RDS CA cert
      # bundle is properly loaded.
      name  = "rds.force_ssl"
      value = 1
    },
    {
      # Log all query statement types (eg, CREATE, DROP, INSERT, DELETE, etc).
      name  = "log_statement"
      value = "all"
    },
    {
      # Minimum query duration (in ms) to log a query.
      name  = "log_min_duration_statement"
      value = 1
    },
    {
      # Log the duration of applied statements.
      name  = "log_duration"
      value = 1
    },
    {
      # Log all connections.
      name  = "log_connections"
      value = 1
    },
    {
      # Log all disconnections.
      name  = "log_disconnections"
      value = 1
    },
    {
      # Max number of concurrent connections from standby servers.
      # The default of ten is being changed by AWS on startup.
      name         = "max_wal_senders"
      value        = 15
      apply_method = "pending-reboot"
    },
  ]
}

# There are a number of other things you may want to add to the DB config
# in addition to these components. Consider things like:
#
# * The Truss RDS snapshot cleaner (https://github.com/trussworks/terraform-aws-rds-snapshot-cleaner)
# * Cloudwatch alarms for running out of burstable CPU credits and storage space
# * Slack alerts for RDS events
