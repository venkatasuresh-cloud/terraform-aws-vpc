# VPC-level outputs

output "vpc_id" {
  description = "ID of the VPC created by this module."
  value       = aws_vpc.this.id
}

output "vpc_arn" {
  description = "ARN of the VPC created by this module."
  value       = aws_vpc.this.arn
}

output "vpc_cidr_block" {
  description = "IPv4 CIDR block assigned to the VPC."
  value       = aws_vpc.this.cidr_block
}

output "availability_zones" {
  description = "Availability Zones used by this VPC."
  value       = var.availability_zones
}

# Outputs for public subnets

output "public_subnet_ids" {
  description = "IDs of the public subnets created by this module."
  value       = values(aws_subnet.public)[*].id
}

output "public_subnet_ids_by_az" {
  description = "Map of Availability Zone to public subnet ID."
  value = {
    for az, subnet in aws_subnet.public :
    az => subnet.id
  }
}

output "public_subnet_cidrs_by_az" {
  description = "Map of Availability Zone to public subnet CIDR block."
  value = {
    for az, subnet in aws_subnet.public :
    az => subnet.cidr_block
  }
}

# Outputs for private subnets

output "private_subnet_ids" {
  description = "IDs of the private subnets created by this module."
  value       = values(aws_subnet.private)[*].id
}

output "private_subnet_ids_by_az" {
  description = "Map of Availability Zone to private subnet ID."
  value = {
    for az, subnet in aws_subnet.private :
    az => subnet.id
  }
}

output "private_subnet_cidrs_by_az" {
  description = "Map of Availability Zone to private subnet CIDR block."
  value = {
    for az, subnet in aws_subnet.private :
    az => subnet.cidr_block
  }
}

# Outputs for database subnets

output "database_subnet_ids" {
  description = "IDs of the database subnets created by this module."
  value       = values(aws_subnet.database)[*].id
}

output "database_subnet_ids_by_az" {
  description = "Map of Availability Zone to database subnet ID."
  value = {
    for az, subnet in aws_subnet.database :
    az => subnet.id
  }
}

output "database_subnet_cidrs_by_az" {
  description = "Map of Availability Zone to database subnet CIDR block."
  value = {
    for az, subnet in aws_subnet.database :
    az => subnet.cidr_block
  }
}

# Route table outputs

output "public_route_table_id" {
  description = "ID of the shared public route table."
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "IDs of the private route tables."
  value       = values(aws_route_table.private)[*].id
}

output "private_route_table_ids_by_az" {
  description = "Map of Availability Zone to private route table ID."
  value = {
    for az, route_table in aws_route_table.private :
    az => route_table.id
  }
}

output "database_route_table_ids" {
  description = "IDs of the isolated database route tables."
  value       = values(aws_route_table.database)[*].id
}

output "database_route_table_ids_by_az" {
  description = "Map of Availability Zone to database route table ID."
  value = {
    for az, route_table in aws_route_table.database :
    az => route_table.id
  }
}

# NAT Gateway outputs

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways created by this module."
  value       = values(aws_nat_gateway.this)[*].id
}

output "nat_gateway_ids_by_az" {
  description = "Map of Availability Zone to NAT Gateway ID."
  value = {
    for az, nat_gateway in aws_nat_gateway.this :
    az => nat_gateway.id
  }
}

output "nat_gateway_public_ips_by_az" {
  description = "Map of Availability Zone to NAT Gateway public IP address."
  value = {
    for az, eip in aws_eip.nat :
    az => eip.public_ip
  }
}

# Internet Gateway outputs

output "internet_gateway_id" {
  description = "ID of the Internet Gateway created by this module."
  value       = aws_internet_gateway.this.id
}

# CIDR reservation outputs

output "future_az_cidr_blocks" {
  description = "CIDR blocks reserved for a future third Availability Zone when the VPC is deployed across two AZs."
  value       = local.future_az_cidr_blocks
}

output "reserved_cidr_blocks" {
  description = "CIDR blocks intentionally reserved for future network expansion."
  value       = local.reserved_cidr_blocks
}