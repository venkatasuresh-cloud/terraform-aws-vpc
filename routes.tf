resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name      = "${var.name}-public-rt"
      RouteType = "public"
    }
  )
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  for_each = local.az_index

  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name      = "${var.name}-private-${each.key}-rt"
      RouteType = "private"
    }
  )
}

resource "aws_route" "private_internet" {
  for_each = aws_route_table.private

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[each.key].id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route_table" "database" {
  for_each = local.az_index

  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name      = "${var.name}-database-${each.key}-rt"
      RouteType = "database"
    }
  )
}

resource "aws_route_table_association" "database" {
  for_each = aws_subnet.database

  subnet_id      = each.value.id
  route_table_id = aws_route_table.database[each.key].id
}