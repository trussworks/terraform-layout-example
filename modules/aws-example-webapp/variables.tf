variable "alb_health_check_path" {
  description = "Path for ALB health check"
  type        = string
  default     = "/health"
}

variable "alb_health_check_interval" {
  description = "Interval for ALB health check (in seconds)"
  type        = number
  default     = 30
}

variable "alb_health_check_timeout" {
  description = "Timeout for ALB health check (in seconds)"
  type        = number
  default     = 5
}

variable "alb_logs_bucket" {
  description = "S3 bucket for ALB logs"
  type        = string
}

variable "alb_subnets" {
  description = "Subnets for ALB"
  type        = list(string)
}

variable "container_port" {
  description = "Port for container listener"
  type        = number
  default     = 8080
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS instance (in GB)"
  type        = number
  default     = 20
}

variable "db_backup_retention" {
  description = "RDS backup retention (in days)"
  type        = number
  default     = 7
}

variable "db_instance_class" {
  description = "Instance class for RDS instance"
  type        = string
  default     = "db.t3.small"
}

variable "db_multi_az" {
  description = "Multi AZ setting for RDS"
  type        = bool
  default     = false
}

variable "db_name" {
  description = "Name for database on RDS instance"
  type        = string
  default     = "my_webapp"
}

variable "db_subnet_group_name" {
  description = "DB subnet group name"
  type        = string
}

variable "db_subnets" {
  description = "List of DB subnets"
  type        = list(string)
}

variable "db_user" {
  description = "User for accessing RDS instance"
  type        = string
  default     = "master"
}

variable "dns_zone_id" {
  description = "Zone ID for DNS"
  type        = string
}

variable "domain_name" {
  description = "Outward facing FQDN for service"
  type        = string
}

variable "ecs_subnets" {
  description = "Subnets for ECS service"
  type        = list(string)
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "final_snapshot_identifier" {
  description = "Final RDS snapshot identifier"
  type        = string
  default     = ""
}

variable "pg_family" {
  description = "DB parameter family for RDS instance"
  type        = string
  default     = "postgres12"
}

variable "pg_version" {
  description = "PostgreSQL version for the RDS instance"
  type        = string
  default     = "12.2"
}

variable "tasks_desired_count" {
  description = "Number of ECS tasks to run"
  type        = number
  default     = 1
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
