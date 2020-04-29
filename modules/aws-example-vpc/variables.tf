variable "cidr_slash16" {
  description = "First 2 octects of the /16 CIDR to use for the VPC."
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "single_nat_gateway" {
  description = "Whether to define a single NAT gateway for all AZs"
  type        = bool
  default     = true
}
