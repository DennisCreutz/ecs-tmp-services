terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = "~> 4.22"
  }

  backend "s3" {
    bucket         = "ecs-tmp-services-global-remote-backend"
    region         = "eu-central-1"
    dynamodb_table = "ecs-tmp-services-global-remote-backend-db"
    key            = "live/ecs-tmp-services/prod/dns/terraform.tfstate"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-central-1"

  default_tags {
    tags = local.default_tags
  }
}

// TODO cycle dep.
data "terraform_remote_state" "ecs" {
  backend = "s3"

  config = {
    bucket = "ecs-tmp-services-global-remote-backend"
    region = "eu-central-1"
    key    = "live/ecs-tmp-services/prod/backend/ecs/terraform.tfstate"
  }
}

resource "aws_route53_zone" "ecs_tmp_service" {
  name = "ecs-tmp-service.aws-prodyna.com"
}

resource "aws_route53_record" "alias_ecs_alb" {
  zone_id = aws_route53_zone.ecs_tmp_service.zone_id
  name    = aws_route53_zone.ecs_tmp_service.name
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.ecs.outputs.alb.dns_name
    zone_id                = data.terraform_remote_state.ecs.outputs.alb.zone_id
    evaluate_target_health = true
  }
}
