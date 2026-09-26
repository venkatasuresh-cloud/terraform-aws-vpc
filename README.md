# terraform-aws-vpc

Reusable Terraform module for building production-oriented AWS VPC networking across multiple Availability Zones.

The module creates a structured network foundation with public, private, and isolated database subnets, deterministic CIDR allocation, per-AZ NAT Gateways, and reusable outputs for downstream AWS infrastructure.

## Overview

This module provides a reusable AWS VPC foundation designed for application and platform workloads such as EC2, ECS, EKS, load balancers, Lambda, RDS, Aurora, ElastiCache, and other VPC-integrated AWS services.

It supports deployments across two or three Availability Zones while maintaining predictable subnet CIDR allocation.

When initially deployed across two Availability Zones, CIDR ranges for a future third Availability Zone are reserved so that expanding to three Availability Zones does not require renumbering the existing subnets.

The module creates:

- One AWS VPC with DNS support and DNS hostnames enabled
- One Internet Gateway
- Public, private, and isolated database subnet tiers
- Support for two or three Availability Zones
- One shared public route table
- One private route table per Availability Zone
- One isolated database route table per Availability Zone
- One public NAT Gateway and Elastic IP per enabled Availability Zone
- Same-AZ NAT routing for private subnets
- Deterministic CIDR allocation with reserved capacity for future expansion
- Common and subnet-specific tagging
- Reusable outputs for integration with other Terraform modules

## Architecture

The module separates workloads into public, private, and isolated database network tiers across multiple Availability Zones.

```text
                         Internet
                            │
                            ▼
                    Internet Gateway
                            │
              ┌─────────────┼─────────────┐
              │             │             │
         Public-A       Public-B       Public-C
              │             │             │
           NAT-A          NAT-B          NAT-C
              │             │             │
              ▼             ▼             ▼
        Private-A      Private-B      Private-C


        Database-A     Database-B     Database-C
             │              │              │
             └──── Isolated subnet tier ───┘
                  No default internet route
```

### Routing Model

Public subnets share a route table containing:

```text
0.0.0.0/0 → Internet Gateway
```

Each private subnet has a dedicated route table and uses the NAT Gateway in the same Availability Zone:

```text
Private-A → Private Route Table-A → NAT-A
Private-B → Private Route Table-B → NAT-B
Private-C → Private Route Table-C → NAT-C
```

Database subnets use dedicated route tables but do not receive a default route to either a NAT Gateway or Internet Gateway.

They retain the VPC-local route, allowing communication with permitted resources inside the VPC while remaining isolated from direct internet routing.

## CIDR Allocation Strategy

The module uses deterministic subnet slots rather than dynamically assigning the next available CIDR range.

This allows a deployment to expand from two Availability Zones to three without changing the CIDRs assigned to the existing Availability Zones.

The allocation model is:

| Slot | Purpose |
|---|---|
| 0 | Public subnet - AZ A |
| 1 | Public subnet - AZ B |
| 2 | Public subnet - AZ C / future AZ |
| 3 | Private subnet - AZ A |
| 4 | Private subnet - AZ B |
| 5 | Private subnet - AZ C / future AZ |
| 6 | Database subnet - AZ A |
| 7 | Database subnet - AZ B |
| 8 | Database subnet - AZ C / future AZ |
| 9 | Reserved |
| 10 | Reserved |

For example, using:

```hcl
vpc_cidr = "10.50.0.0/20"
```

and allowing the module to determine the subnet prefix automatically results in `/24` subnet ranges.

### Two-AZ Deployment

```text
Public-A     → 10.50.0.0/24
Public-B     → 10.50.1.0/24
Public-C     → 10.50.2.0/24  reserved

Private-A    → 10.50.3.0/24
Private-B    → 10.50.4.0/24
Private-C    → 10.50.5.0/24  reserved

Database-A   → 10.50.6.0/24
Database-B   → 10.50.7.0/24
Database-C   → 10.50.8.0/24  reserved

Reserved     → 10.50.9.0/24
Reserved     → 10.50.10.0/24
```

Only six AWS subnets are created in this scenario.

The third-AZ ranges are reserved logically and are not created as AWS subnet resources.

### Three-AZ Deployment

When a third Availability Zone is enabled:

```text
Public-A     → 10.50.0.0/24
Public-B     → 10.50.1.0/24
Public-C     → 10.50.2.0/24

Private-A    → 10.50.3.0/24
Private-B    → 10.50.4.0/24
Private-C    → 10.50.5.0/24

Database-A   → 10.50.6.0/24
Database-B   → 10.50.7.0/24
Database-C   → 10.50.8.0/24
```

The existing AZ-A and AZ-B subnet CIDRs remain unchanged.

## Requirements

| Component | Requirement |
|---|---|
| Terraform | >= 1.9.0 |
| AWS Provider | >= 6.0.0 |

The AWS provider must be configured by the root module consuming this module.

The reusable module does not configure AWS credentials, account IDs, regions, or IAM roles.

Example root provider configuration:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

## Usage

### Two Availability Zones

```hcl
module "vpc" {
  source = "github.com/venkatasuresh-cloud/terraform-aws-vpc"

  name     = "platform-dev"
  vpc_cidr = "10.50.0.0/20"

  availability_zones = [
    "us-east-1a",
    "us-east-1b"
  ]

  tags = {
    Environment = "dev"
    Application = "platform"
    Managed_by  = "Terraform"
  }
}
```

This creates:

```text
2 public subnets
2 private subnets
2 database subnets

1 shared public route table
2 private route tables
2 database route tables

2 NAT Gateways
2 Elastic IPs
```

### Three Availability Zones

```hcl
module "vpc" {
  source = "github.com/venkatasuresh-cloud/terraform-aws-vpc"

  name     = "platform-prod"
  vpc_cidr = "10.50.0.0/20"

  availability_zones = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c"
  ]

  tags = {
    Environment = "prod"
    Application = "platform"
    Managed_by  = "Terraform"
  }
}
```

This creates:

```text
3 public subnets
3 private subnets
3 database subnets

1 shared public route table
3 private route tables
3 database route tables

3 NAT Gateways
3 Elastic IPs
```

## Subnet-Specific Tags

Additional tags can be applied independently to each subnet tier.

For example:

```hcl
module "vpc" {
  source = "github.com/venkatasuresh-cloud/terraform-aws-vpc"

  name     = "platform-dev"
  vpc_cidr = "10.50.0.0/20"

  availability_zones = [
    "us-east-1a",
    "us-east-1b"
  ]

  tags = {
    Environment = "dev"
    Application = "platform"
    Managed_by  = "Terraform"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}
```

Subnet-specific tags allow downstream platforms or services to add discovery or organizational metadata without making this module dependent on a particular workload such as EKS.

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| `name` | Name prefix used for resources created by the module | `string` | n/a | Yes |
| `vpc_cidr` | IPv4 CIDR assigned to the VPC | `string` | n/a | Yes |
| `availability_zones` | Availability Zones used by the VPC. Exactly 2 or 3 are supported | `list(string)` | n/a | Yes |
| `tags` | Common tags applied to resources. `Environment`, `Application`, and `Managed_by` are required | `map(string)` | n/a | Yes |
| `subnet_prefix_length` | Optional subnet prefix length. When omitted, enough address space is allocated for 16 subnet slots | `number` | `null` | No |
| `public_subnet_tags` | Additional tags applied to public subnets | `map(string)` | `{}` | No |
| `private_subnet_tags` | Additional tags applied to private subnets | `map(string)` | `{}` | No |
| `database_subnet_tags` | Additional tags applied to database subnets | `map(string)` | `{}` | No |

### VPC CIDR Validation

The current module supports VPC CIDR prefix lengths from:

```text
/16 through /24
```

The subnet allocation strategy reserves enough address space for at least 16 subnet slots.

AWS IPv4 subnet sizing requirements are also respected by preventing subnet prefix lengths greater than `/28`.

## Required Tags

The following common tags are mandatory:

```text
Environment
Application
Managed_by
```

For example:

```hcl
tags = {
  Environment = "dev"
  Application = "payments"
  Managed_by  = "Terraform"
}
```

Additional tags may also be supplied.

Resource-specific `Name` and subnet/route classification tags are generated by the module.

## Outputs

The module exposes reusable networking information for downstream infrastructure.

### VPC

- `vpc_id`
- `vpc_arn`
- `vpc_cidr_block`
- `availability_zones`
- `internet_gateway_id`

### Public Networking

- `public_subnet_ids`
- `public_subnet_ids_by_az`
- `public_subnet_cidrs_by_az`
- `public_route_table_id`

### Private Networking

- `private_subnet_ids`
- `private_subnet_ids_by_az`
- `private_subnet_cidrs_by_az`
- `private_route_table_ids`
- `private_route_table_ids_by_az`

### Database Networking

- `database_subnet_ids`
- `database_subnet_ids_by_az`
- `database_subnet_cidrs_by_az`
- `database_route_table_ids`
- `database_route_table_ids_by_az`

### NAT

- `nat_gateway_ids`
- `nat_gateway_ids_by_az`
- `nat_gateway_public_ips_by_az`

### CIDR Planning

- `future_az_cidr_blocks`
- `reserved_cidr_blocks`

These outputs can be consumed by modules managing services such as EC2, ECS, EKS, Auto Scaling Groups, ALB/NLB, Lambda, RDS, Aurora, ElastiCache, VPC endpoints, and other VPC-integrated infrastructure.

## Design Decisions

### Generic VPC Foundation

This module is intentionally not tied to a specific compute or container platform.

It provides networking that can be consumed by EC2, ECS, EKS, databases, load balancers, serverless workloads, and other AWS infrastructure.

Platform-specific functionality should remain in the consuming modules.

### One NAT Gateway Per Availability Zone

Each enabled Availability Zone receives its own public NAT Gateway.

Private subnet traffic therefore uses the NAT Gateway located in the same Availability Zone.

This avoids introducing a normal dependency on cross-AZ NAT routing and provides an Availability Zone-aligned network design.

NAT Gateways incur AWS charges, so consumers should consider the cost implications when selecting the number of Availability Zones.

### Shared Public Route Table

All public subnets use a single public route table because they share the same routing requirement:

```text
0.0.0.0/0 → Internet Gateway
```

### Dedicated Private Route Tables

Private subnets use one route table per Availability Zone so each private subnet can route through its corresponding NAT Gateway.

### Isolated Database Tier

Database subnets do not receive a default route to the Internet Gateway or NAT Gateway.

They retain VPC-local connectivity and can be consumed by database-oriented services or other workloads requiring an isolated network tier.

### Public IP Assignment

Public subnets are created with:

```hcl
map_public_ip_on_launch = false
```

A public subnet is defined by its route to the Internet Gateway, not by automatically assigning public IP addresses to every workload launched in the subnet.

Workloads requiring a public IPv4 address should configure that requirement explicitly.

## Examples

Example configurations are available under:

```text
examples/
├── two-az/
└── three-az/
```

The examples demonstrate how a root Terraform configuration consumes the reusable module.

## Validation

The module has been validated using:

```bash
terraform fmt
terraform validate
terraform plan
```

The current example plans produce:

```text
Two-AZ example
Plan: 26 to add, 0 to change, 0 to destroy

Three-AZ example
Plan: 37 to add, 0 to change, 0 to destroy
```

The three-AZ plan also confirms that enabling the third Availability Zone consumes the pre-reserved subnet CIDRs while preserving the existing AZ-A and AZ-B CIDRs.

At this stage, validation has focused on Terraform configuration and planning. AWS deployment testing will be performed separately before describing the module as production-ready.

## Current Scope

The initial module focuses on the core IPv4 VPC networking foundation.

Features such as the following are intentionally outside the current scope and may be introduced separately as requirements evolve:

- VPC Flow Logs
- VPC endpoints
- IPv6
- Transit Gateway integration
- VPN connectivity
- Network Firewall
- NAT Gateway cost-optimization modes
- Custom DHCP options
- Advanced network ACL management

Keeping these concerns separate avoids making the core VPC module unnecessarily complex.

## Repository Structure

```text
terraform-aws-vpc/
├── examples/
│   ├── two-az/
│   └── three-az/
├── locals.tf
├── nat.tf
├── outputs.tf
├── routes.tf
├── subnets.tf
├── variables.tf
├── versions.tf
├── vpc.tf
└── README.md
```

## Status

The module currently provides the initial reusable AWS VPC networking foundation.

Planned engineering improvements include automated Terraform validation, testing, and CI workflows.