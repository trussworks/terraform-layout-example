# We add an output for the VPC's NAT EIPs, so that we can give these to
# a third party in case they need to add it to a firewall.
output "vpc_nat_eips" {
  description = "External IPs used by NAT gateways"
  value       = module.prod_vpc.nat_eips
}
