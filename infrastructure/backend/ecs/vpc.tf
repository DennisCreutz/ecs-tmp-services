data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.14"

  name               = "${local.prefix}-ecs"
  cidr               = "172.16.0.0/16"
  azs                = data.aws_availability_zones.available.names
  private_subnets    = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
  public_subnets     = ["172.16.4.0/24", "172.16.5.0/24", "172.16.6.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true
}
