terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = "~> 4.22"
  }

  backend "s3" {
    bucket         = "ecs-tmp-services-global-remote-backend"
    region         = "eu-central-1"
    dynamodb_table = "ecs-tmp-services-global-remote-backend-db"
    key            = "live/ecs-tmp-services/prod/data/aurora/terraform.tfstate"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-central-1"
}

module "aurora_serverless" {
  source = "../../../modules/aurora-serverless"

  stage   = local.stage
  project = local.project

  vpc_name          = "vpc"
  vpc_cidr          = "192.168.0.0/20"
  create_vpce       = false
  create_nat        = false
  create_s3_gateway = false

  aurora_name = "aurora-serverless"
  scaling_configuration = {
    auto_pause               = true
    min_capacity             = 1
    max_capacity             = 4
    seconds_until_auto_pause = 1200
    timeout_action           = "ForceApplyCapacityChange"
  }
  preferred_backup_window             = "02:00-03:00"
  preferred_maintenance_window        = "sun:03:00-sun:04:00"
  public_subnet_cidrs                 = ["192.168.12.0/24", "192.168.13.0/24", "192.168.14.0/24"]
  private_subnet_cidrs                = ["192.168.0.0/22", "192.168.4.0/22", "192.168.8.0/22"]
  backup_retention_period             = 1
  iam_database_authentication_enabled = false

  // TODO
  security_group_configuration = {
    ingress = {
      from_port        = 3306
      to_port          = 3306
      protocol         = "TCP"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    egress = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
