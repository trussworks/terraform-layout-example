output "vpc_id" {
  description = "The ID of the VPC."
  value       = module.vpc.vpc_id
}

output "vpc_name" {
  description = "The name of the VPC."
  value       = module.vpc.name
}

output "nat_eips" {
  description = "List of EIPs for NAT gateways."
  value       = aws_eip.nat.*.id
}

output "private_subnets" {
  description = "List of IDs of private subnets."
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets."
  value       = module.vpc.public_subnets
}

output "database_subnets" {
  description = "List of IDs of DB subnets."
  value       = module.vpc.database_subnets
}
