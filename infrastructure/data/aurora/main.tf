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

resource "aws_iam_role" "additional_role" {
  name = "${local.prefix}-additional"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "rds.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

// TODO cycle dep.
resource "aws_iam_policy" "invoke_create_tmp_service" {
  name        = "${local.prefix}-invoke-create-tmp-service"
  path        = "/"
  description = "IAM policy for invoking the create tmp service Lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "invoke_create_tmp_service_lambda" {
  role       = aws_iam_role.additional_role.name
  policy_arn = aws_iam_policy.invoke_create_tmp_service.arn
}

module "aurora" {
  source = "../../../modules/aurora"

  stage   = local.stage
  project = local.project

  vpc_name          = "vpc"
  vpc_cidr          = "192.168.0.0/20"
  create_vpce       = false
  create_nat        = true
  create_s3_gateway = false


  instances = {
    1 = {
      instance_class      = "db.t4g.medium"
      publicly_accessible = false
    }
  }

  aws_default_lambda_role = aws_iam_role.additional_role.arn

  aurora_name                         = "aurora"
  preferred_backup_window             = "02:00-03:00"
  preferred_maintenance_window        = "sun:03:00-sun:04:00"
  public_subnet_cidrs                 = ["192.168.12.0/24", "192.168.13.0/24", "192.168.14.0/24"]
  private_subnet_cidrs                = ["192.168.0.0/22", "192.168.4.0/22", "192.168.8.0/22"]
  backup_retention_period             = 1
  iam_database_authentication_enabled = false

  security_group_egress_rules = {
    egress = {
      from_port   = 0
      to_port     = 65535
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
