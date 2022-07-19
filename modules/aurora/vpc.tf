data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "database" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = merge(
    local.default_tags,
    {
      Name = local.vpc_name
  })
}

resource "aws_internet_gateway" "database" {
  vpc_id = aws_vpc.database.id

  tags = local.default_tags
}

# Public Subnet
resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnet_cidrs)

  vpc_id = aws_vpc.database.id

  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
  map_public_ip_on_launch = true

  tags = merge(
    local.default_tags,
    {
      Name = "${local.vpc_name}-pub-${count.index}"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.database.id

  tags = local.default_tags
}
resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.database.id

  depends_on = [aws_internet_gateway.database]
}

resource "aws_route_table_association" "public_subnet" {
  count = length(var.public_subnet_cidrs)

  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Subnets
resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnet_cidrs)

  vpc_id = aws_vpc.database.id

  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
  map_public_ip_on_launch = false

  tags = merge(
    local.default_tags,
    {
      Name = "${local.vpc_name}-priv-${count.index}"
  })
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.database.id

  tags = local.default_tags
}

resource "aws_route_table_association" "private_subnets" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private.id
}

# NAT
resource "aws_nat_gateway" "this" {
  count = var.create_nat == true ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public_subnets[0].id

  tags = local.default_tags
}

resource "aws_eip" "nat" {
  count = var.create_nat == true ? 1 : 0

  depends_on = [aws_internet_gateway.database]
}

resource "aws_route" "nat" {
  count = var.create_nat == true ? 1 : 0

  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id

  depends_on = [aws_internet_gateway.database, aws_nat_gateway.this]
}
