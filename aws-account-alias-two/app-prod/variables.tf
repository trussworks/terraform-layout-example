variable "environment" {
  type = "string"
}

variable "cidr_slash16" {
  description = "First 2 octects of the /16 CIDR to use for the VPC."
  type        = "string"
}

variable "single_nat_gateway" {
  default     = false
  description = "Whether to provision a single shared NAT Gateway across all the private networks."
  type        = "string"
}
