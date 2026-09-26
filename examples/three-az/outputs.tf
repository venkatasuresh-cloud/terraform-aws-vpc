output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "database_subnet_ids" {
  value = module.vpc.database_subnet_ids
}

output "nat_gateway_public_ips_by_az" {
  value = module.vpc.nat_gateway_public_ips_by_az
}

output "future_az_cidr_blocks" {
  value = module.vpc.future_az_cidr_blocks
}