resource "aws_vpc_endpoint" "ssm_vpce" {
  count             = var.create_vpce == true ? 1 : 0
  vpc_id            = aws_vpc.database.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.private_subnets.*.id
  security_group_ids = [
  aws_security_group.ssm_vpce_sg[0].id]
  private_dns_enabled = true

  tags = merge(
    local.default_tags,
    {
      Name = "${local.vpce_name}"
  })
}

resource "aws_security_group" "ssm_vpce_sg" {
  count = var.security_group_configuration != null ? 1 : 0

  name        = "${local.prefix}-ssm-vpce-sg-${count.index}"
  description = "SG for the ssm vpce sg."

  vpc_id = aws_vpc.database.id

  tags = local.default_tags
}

resource "aws_security_group_rule" "ssm_vpce_sgr_ingress" {
  count = var.security_group_configuration != null ? 1 : 0

  security_group_id = aws_security_group.ssm_vpce_sg[0].id
  type              = "ingress"
  from_port         = var.security_group_configuration.ingress.from_port
  to_port           = var.security_group_configuration.ingress.to_port
  protocol          = var.security_group_configuration.ingress.protocol
  cidr_blocks       = var.security_group_configuration.ingress.cidr_blocks
}

resource "aws_security_group_rule" "ssm_vpce_sgr_egress" {
  count = var.security_group_configuration != null ? 1 : 0

  security_group_id = aws_security_group.ssm_vpce_sg[0].id
  type              = "egress"
  from_port         = var.security_group_configuration.ingress.from_port
  to_port           = var.security_group_configuration.ingress.to_port
  protocol          = var.security_group_configuration.ingress.protocol
  cidr_blocks       = var.security_group_configuration.ingress.cidr_blocks
}

resource "aws_vpc_endpoint" "s3" {
  count = var.create_s3_gateway == true ? 1 : 0

  vpc_id            = aws_vpc.database.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = aws_route_table.private.*.id

  tags = merge(
    local.default_tags,
    {
      Name = "${local.vpce_name}"
  })
}
