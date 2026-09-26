variable "name" {
  description = "Name prefix used for resources created by this VPC module."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "The name variable must not be empty."
  }
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block assigned to the VPC. This module supports VPC CIDR prefixes from /16 through /24."
  type        = string

  validation {
    condition = (
      can(cidrnetmask(var.vpc_cidr)) &&
      tonumber(split("/", var.vpc_cidr)[1]) >= 16 &&
      tonumber(split("/", var.vpc_cidr)[1]) <= 24
    )

    error_message = "vpc_cidr must be a valid IPv4 CIDR block with a prefix length between /16 and /24."
  }
}

variable "availability_zones" {
  description = "Availability Zones in which the VPC subnets will be created. Exactly 2 or 3 AZs are supported."
  type        = list(string)

  validation {
    condition = (
      length(var.availability_zones) >= 2 &&
      length(var.availability_zones) <= 3
    )

    error_message = "availability_zones must contain either 2 or 3 Availability Zones."
  }

  validation {
    condition     = length(distinct(var.availability_zones)) == length(var.availability_zones)
    error_message = "availability_zones must not contain duplicate Availability Zones."
  }
}

variable "tags" {
  description = "Common tags applied to resources created by this module. Environment, Application, and Managed_by are mandatory."
  type        = map(string)

  validation {
    condition = alltrue([
      for key in ["Environment", "Application", "Managed_by"] :
      contains(keys(var.tags), key)
    ])

    error_message = "tags must include Environment, Application, and Managed_by."
  }

  validation {
    condition = alltrue([
      for key in ["Environment", "Application", "Managed_by"] :
      try(length(trimspace(var.tags[key])) > 0, false)
    ])

    error_message = "Environment, Application, and Managed_by tag values must not be empty."
  }
}

variable "subnet_prefix_length" {
  description = "Prefix length used for subnets created within the VPC. If not provided, the module automatically allocates enough address space for 16 subnet slots."
  type        = number
  default     = null

  validation {
    condition = (
      var.subnet_prefix_length == null ||
      (
        var.subnet_prefix_length >= tonumber(split("/", var.vpc_cidr)[1]) + 4 &&
        var.subnet_prefix_length <= 28
      )
    )

    error_message = "subnet_prefix_length must provide at least 16 subnet blocks within the VPC and cannot be greater than /28."
  }
}

variable "public_subnet_tags" {
  description = "Additional tags applied only to public subnets."
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags applied only to private subnets."
  type        = map(string)
  default     = {}
}

variable "database_subnet_tags" {
  description = "Additional tags applied only to database subnets."
  type        = map(string)
  default     = {}
}