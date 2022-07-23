terraform {
  required_version = "~> 1.0"

  required_providers {
    aws      = "~> 4.22"
  }

  backend "s3" {
    bucket         = "ecs-tmp-services-global-remote-backend"
    region         = "eu-central-1"
    dynamodb_table = "ecs-tmp-services-global-remote-backend-db"
    key            = "live/ecs-tmp-services/prod/backend/ecs/terraform.tfstate"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-central-1"

  default_tags {
    tags = local.default_tags
  }
}


