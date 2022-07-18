terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = "~> 4.22"
  }

  backend "s3" {
    bucket         = "ecs-tmp-services-global-remote-backend"
    region         = "eu-central-1"
    dynamodb_table = "ecs-tmp-services-global-remote-backend-db"
    key            = "live/ecs-tmp-services/prod/data/aurora-access/terraform.tfstate"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-central-1"
}

data "terraform_remote_state" "aurora" {
  backend = "s3"

  config = {
    bucket = "ecs-tmp-services-global-remote-backend"
    region = "eu-central-1"
    key    = "live/ecs-tmp-services/prod/data/aurora/terraform.tfstate"
  }
}

data "terraform_remote_state" "dns" {
  backend = "s3"

  config = {
    bucket = "ecs-tmp-services-global-remote-backend"
    region = "eu-central-1"
    key    = "live/ecs-tmp-services/prod/dns/terraform.tfstate"
  }
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = "${local.prefix}-bastion"
  public_key = tls_private_key.this.public_key_openssh
}

module "aurora_access" {
  source = "../../../modules/database-access"

  stage   = local.stage
  project = "ets" // needs to be shorter...

  vpc_id             = data.terraform_remote_state.aurora.outputs.vpc_id
  bastion_subnet_ids = data.terraform_remote_state.aurora.outputs.public_subnets.*.id
  lb_subnet_ids      = data.terraform_remote_state.aurora.outputs.public_subnets.*.id

  bastion_host_key_pair = aws_key_pair.this.key_name
  log_expiry_days       = 90

  dns_hosted_zone     = data.terraform_remote_state.dns.outputs.zone_id
  bastion_record_name = "database.${data.terraform_remote_state.dns.outputs.name}"
}
