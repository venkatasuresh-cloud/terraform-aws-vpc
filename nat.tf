resource "aws_eip" "nat" {
  for_each = local.az_index

  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-nat-eip-${each.key}"
    }
  )
}

resource "aws_nat_gateway" "this" {
  for_each = aws_subnet.public

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id

  connectivity_type = "public"

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-nat-${each.key}"
    }
  )

  depends_on = [aws_internet_gateway.this]
}