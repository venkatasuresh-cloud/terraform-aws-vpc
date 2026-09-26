resource "aws_subnet" "public" {
  for_each = local.public_subnet_cidrs

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = each.value

  map_public_ip_on_launch = false

  tags = merge(
    var.public_subnet_tags,
    var.tags,
    {
      Name       = "${var.name}-public-${each.key}"
      SubnetType = "public"
    }
  )
}

resource "aws_subnet" "private" {
  for_each = local.private_subnet_cidrs

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = each.value

  map_public_ip_on_launch = false

  tags = merge(
    var.private_subnet_tags,
    var.tags,
    {
      Name       = "${var.name}-private-${each.key}"
      SubnetType = "private"
    }
  )
}

resource "aws_subnet" "database" {
  for_each = local.database_subnet_cidrs

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = each.value

  map_public_ip_on_launch = false

  tags = merge(
    var.database_subnet_tags,
    var.tags,
    {
      Name       = "${var.name}-database-${each.key}"
      SubnetType = "database"
    }
  )
}   