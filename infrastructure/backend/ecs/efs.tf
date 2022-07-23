resource "aws_efs_file_system" "libs" {
  encrypted = true
}

resource "aws_efs_mount_target" "libs_mount" {
  count = length(module.vpc.private_subnets)

  file_system_id = aws_efs_file_system.libs.id
  subnet_id      = module.vpc.private_subnets[count.index]

  security_groups = [aws_security_group.libs.id]
}

resource "aws_security_group" "libs" {
  name   = "${local.prefix}-efs-libs"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 2049
    to_port         = 2049
    security_groups = [aws_security_group.config_service.id]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
