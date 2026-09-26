locals {
  vpc_prefix_length = tonumber(split("/", var.vpc_cidr)[1])

  effective_subnet_prefix_length = coalesce(
    var.subnet_prefix_length,
    local.vpc_prefix_length + 4
  )

  subnet_newbits = (
    local.effective_subnet_prefix_length -
    local.vpc_prefix_length
  )

  az_index = {
    for index, az in var.availability_zones :
    az => index
  }

  subnet_slot_offsets = {
    public   = 0
    private  = 3
    database = 6
  }

  public_subnet_cidrs = {
    for az, index in local.az_index :
    az => cidrsubnet(
      var.vpc_cidr,
      local.subnet_newbits,
      local.subnet_slot_offsets.public + index
    )
  }

  private_subnet_cidrs = {
    for az, index in local.az_index :
    az => cidrsubnet(
      var.vpc_cidr,
      local.subnet_newbits,
      local.subnet_slot_offsets.private + index
    )
  }

  database_subnet_cidrs = {
    for az, index in local.az_index :
    az => cidrsubnet(
      var.vpc_cidr,
      local.subnet_newbits,
      local.subnet_slot_offsets.database + index
    )
  }

  future_az_cidr_blocks = length(var.availability_zones) == 2 ? {
    public   = cidrsubnet(var.vpc_cidr, local.subnet_newbits, 2)
    private  = cidrsubnet(var.vpc_cidr, local.subnet_newbits, 5)
    database = cidrsubnet(var.vpc_cidr, local.subnet_newbits, 8)
  } : {}

  reserved_cidr_blocks = {
    reserved_1 = cidrsubnet(var.vpc_cidr, local.subnet_newbits, 9)
    reserved_2 = cidrsubnet(var.vpc_cidr, local.subnet_newbits, 10)
  }
}