mock_provider "aws" {}

run "three_az_network_layout" {
  command = plan

  variables {
    name     = "test-vpc"
    vpc_cidr = "10.50.0.0/20"

    availability_zones = [
      "us-east-1a",
      "us-east-1b",
      "us-east-1c"
    ]

    tags = {
      Environment = "test"
      Application = "terraform-test"
      Managed_by  = "Terraform"
    }
  }

  assert {
    condition     = length(aws_subnet.public) == 3
    error_message = "Expected exactly three public subnets."
  }

  assert {
    condition     = length(aws_subnet.private) == 3
    error_message = "Expected exactly three private subnets."
  }

  assert {
    condition     = length(aws_subnet.database) == 3
    error_message = "Expected exactly three database subnets."
  }

  assert {
    condition = (
      local.public_subnet_cidrs["us-east-1a"] == "10.50.0.0/24" &&
      local.public_subnet_cidrs["us-east-1b"] == "10.50.1.0/24" &&
      local.public_subnet_cidrs["us-east-1c"] == "10.50.2.0/24"
    )

    error_message = "Public subnet CIDRs do not match the expected three-AZ allocation."
  }

  assert {
    condition = (
      local.private_subnet_cidrs["us-east-1a"] == "10.50.3.0/24" &&
      local.private_subnet_cidrs["us-east-1b"] == "10.50.4.0/24" &&
      local.private_subnet_cidrs["us-east-1c"] == "10.50.5.0/24"
    )

    error_message = "Private subnet CIDRs do not match the expected three-AZ allocation."
  }

  assert {
    condition = (
      local.database_subnet_cidrs["us-east-1a"] == "10.50.6.0/24" &&
      local.database_subnet_cidrs["us-east-1b"] == "10.50.7.0/24" &&
      local.database_subnet_cidrs["us-east-1c"] == "10.50.8.0/24"
    )

    error_message = "Database subnet CIDRs do not match the expected three-AZ allocation."
  }

  assert {
    condition     = length(local.future_az_cidr_blocks) == 0
    error_message = "No future third-AZ CIDR blocks should remain when three AZs are enabled."
  }
}
