terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = "~> 4.22"
  }

  backend "s3" {
    bucket         = "ecs-tmp-services-global-remote-backend"
    region         = "eu-central-1"
    dynamodb_table = "ecs-tmp-services-global-remote-backend-db"
    key            = "live/ecs-tmp-services/prod/networking/vpc-peering/terraform.tfstate"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-central-1"
}

data "terraform_remote_state" "ecs" {
  backend = "s3"

  config = {
    bucket = "ecs-tmp-services-global-remote-backend"
    region = "eu-central-1"
    key    = "live/ecs-tmp-services/prod/backend/ecs/terraform.tfstate"
  }
}

data "terraform_remote_state" "aurora" {
  backend = "s3"

  config = {
    bucket = "ecs-tmp-services-global-remote-backend"
    region = "eu-central-1"
    key    = "live/ecs-tmp-services/prod/data/aurora/terraform.tfstate"
  }
}

resource "aws_vpc_peering_connection" "ecs_to_aurora" {
  peer_vpc_id = data.terraform_remote_state.aurora.outputs.vpc_id
  vpc_id      = data.terraform_remote_state.ecs.outputs.vpc_id
  auto_accept = true
}

resource "aws_route" "aurora_to_ecs" {
  count = length(data.terraform_remote_state.ecs.outputs.private_subnets_cidr_blocks)

  route_table_id            = data.terraform_remote_state.aurora.outputs.private_route_table_id
  destination_cidr_block    = data.terraform_remote_state.ecs.outputs.private_subnets_cidr_blocks[count.index]
  vpc_peering_connection_id = aws_vpc_peering_connection.ecs_to_aurora.id
}

resource "aws_route" "ecs_to_aurora" {
  count = length(data.terraform_remote_state.aurora.outputs.private_subnets.*.id)

  route_table_id            = data.terraform_remote_state.ecs.outputs.private_route_table_ids.0
  destination_cidr_block    = data.terraform_remote_state.aurora.outputs.private_subnets.*.cidr_block[count.index]
  vpc_peering_connection_id = aws_vpc_peering_connection.ecs_to_aurora.id
}
