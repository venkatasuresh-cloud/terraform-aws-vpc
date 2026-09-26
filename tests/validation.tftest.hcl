mock_provider "aws" {}

run "reject_single_availability_zone" {
  command = plan

  variables {
    name     = "test-vpc"
    vpc_cidr = "10.50.0.0/20"

    availability_zones = [
      "us-east-1a"
    ]

    tags = {
      Environment = "test"
      Application = "terraform-test"
      Managed_by  = "Terraform"
    }
  }

  expect_failures = [
    var.availability_zones
  ]
}

run "reject_four_availability_zones" {
  command = plan

  variables {
    name     = "test-vpc"
    vpc_cidr = "10.50.0.0/20"

    availability_zones = [
      "us-east-1a",
      "us-east-1b",
      "us-east-1c",
      "us-east-1d"
    ]

    tags = {
      Environment = "test"
      Application = "terraform-test"
      Managed_by  = "Terraform"
    }
  }

  expect_failures = [
    var.availability_zones
  ]
}

run "reject_duplicate_availability_zones" {
  command = plan

  variables {
    name     = "test-vpc"
    vpc_cidr = "10.50.0.0/20"

    availability_zones = [
      "us-east-1a",
      "us-east-1a"
    ]

    tags = {
      Environment = "test"
      Application = "terraform-test"
      Managed_by  = "Terraform"
    }
  }

  expect_failures = [
    var.availability_zones
  ]
}

run "reject_vpc_cidr_smaller_than_supported" {
  command = plan

  variables {
    name     = "test-vpc"
    vpc_cidr = "10.50.0.0/25"

    availability_zones = [
      "us-east-1a",
      "us-east-1b"
    ]

    tags = {
      Environment = "test"
      Application = "terraform-test"
      Managed_by  = "Terraform"
    }
  }

  expect_failures = [
    var.vpc_cidr
  ]
}

run "reject_missing_required_tags" {
  command = plan

  variables {
    name     = "test-vpc"
    vpc_cidr = "10.50.0.0/20"

    availability_zones = [
      "us-east-1a",
      "us-east-1b"
    ]

    tags = {
      Environment = "test"
      Application = "terraform-test"
    }
  }

  expect_failures = [
    var.tags
  ]
}

run "reject_empty_required_tag_value" {
  command = plan

  variables {
    name     = "test-vpc"
    vpc_cidr = "10.50.0.0/20"

    availability_zones = [
      "us-east-1a",
      "us-east-1b"
    ]

    tags = {
      Environment = "test"
      Application = "terraform-test"
      Managed_by  = ""
    }
  }

  expect_failures = [
    var.tags
  ]
}

run "reject_invalid_subnet_prefix_length" {
  command = plan

  variables {
    name                 = "test-vpc"
    vpc_cidr             = "10.50.0.0/20"
    subnet_prefix_length = 23

    availability_zones = [
      "us-east-1a",
      "us-east-1b"
    ]

    tags = {
      Environment = "test"
      Application = "terraform-test"
      Managed_by  = "Terraform"
    }
  }

  expect_failures = [
    var.subnet_prefix_length
  ]
}