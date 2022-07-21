terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = "~> 4.22"
  }

  backend "s3" {
    bucket         = "ecs-tmp-services-global-remote-backend"
    region         = "eu-central-1"
    dynamodb_table = "ecs-tmp-services-global-remote-backend-db"
    key            = "live/ecs-tmp-services/prod/backend/lambda/create-tmp-service/terraform.tfstate"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-central-1"
}

data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket = "ecs-tmp-services-global-remote-backend"
    region = "eu-central-1"
    key    = "live/ecs-tmp-services/prod/data/aurora/terraform.tfstate"
  }
}

module "create_tmp_service" {
  source = "../../../../modules/lambda"

  stage   = local.stage
  project = local.project

  lambda_name   = local.lambda_name
  source_dir    = "${path.module}/app/built"
  timeout       = 60
  memory_size   = 512
  log_retention = 7
  enable_xray   = true

  subnet_ids = data.terraform_remote_state.db.outputs.private_subnets.*.id

  // TODO
  security_group_configuration = {
    vpc_id = data.terraform_remote_state.db.outputs.vpc_id
    ingress = {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
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

  additional_lambda_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ssm:GetParametersByPath",
        "ssm:GetParameters",
        "ssm:GetParameter"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}
