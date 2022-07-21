terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = "~> 4.22"
  }

  backend "s3" {
    bucket         = "ecs-tmp-services-global-remote-backend"
    region         = "eu-central-1"
    key            = "live/ecs-tmp-services/prod/registry/ecr/terraform.tfstate"
    dynamodb_table = "ecs-tmp-services-global-remote-backend-db"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-central-1"

  default_tags {
    tags = local.default_tags
  }
}

module "ecr_config_service" {
  source  = "cloudposse/ecr/aws"
  version = "~> 0.34"

  name = "config-service"

  image_tag_mutability = "MUTABLE"
}

module "ecr_tmp_service" {
  source  = "cloudposse/ecr/aws"
  version = "~> 0.34"

  name = "tmp-service"

  image_tag_mutability = "MUTABLE"
}
