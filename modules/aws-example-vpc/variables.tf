variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "cidr_slash16" {
  description = "First 2 octects of the /16 CIDR to use for the VPC."
  type        = string
}
