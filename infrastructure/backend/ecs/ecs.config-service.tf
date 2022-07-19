data "terraform_remote_state" "ecr" {
  backend = "s3"

  config = {
    bucket = "ecs-tmp-services-global-remote-backend"
    region = "eu-central-1"
    key    = "live/ecs-tmp-services/prod/registry/ecr/terraform.tfstate"
  }
}

data "aws_ecr_image" "config_service" {
  repository_name = data.terraform_remote_state.ecr.outputs.config_service_repo_name
  image_tag       = "latest"
}

data "aws_ecs_task_definition" "config_service" {
  task_definition = aws_ecs_task_definition.config_service.family
}

/*
  TODO: Ugly! Must be created manually before apply
*/
data "aws_ssm_parameter" "db_host" {
  name = "/${local.project}/${local.stage}/database/host"
}
data "aws_ssm_parameter" "db_port" {
  name = "/${local.project}/${local.stage}/database/port"
}
data "aws_ssm_parameter" "db" {
  name = "/${local.project}/${local.stage}/database/database"
}
data "aws_ssm_parameter" "db_user" {
  name = "/${local.project}/${local.stage}/database/root-user-name"
}
data "aws_ssm_parameter" "db_pw" {
  name = "/${local.project}/${local.stage}/database/root-user-pwd"
}

resource "aws_ecs_task_definition" "config_service" {
  family = "${local.prefix}-config-service"

  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]

  cpu                = 256
  memory             = 512
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = local.config_service_container_name
      image     = "${data.terraform_remote_state.ecr.outputs.config_service_image_url}:latest@${data.aws_ecr_image.config_service.image_digest}"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      environment = [
        {
          name  = "DB_HOST",
          value = data.aws_ssm_parameter.db_host.value
        },
        {
          name  = "DB_PORT",
          value = data.aws_ssm_parameter.db_port.value
        },
        {
          name  = "DB",
          value = data.aws_ssm_parameter.db.value
        },
        {
          name  = "DB_USER",
          value = data.aws_ssm_parameter.db_user.value
        },
        {
          name  = "DB_PW",
          value = data.aws_ssm_parameter.db_pw.value
        },
      ]
      logConfiguration : {
        logDriver : "awslogs",
        options : {
          "awslogs-group" : "/ecs/${local.prefix}-config-service",
          "awslogs-region" : "eu-central-1",
          "awslogs-stream-prefix" : "config-service"
        }
      }
    }
  ])
}

// TODO placement_constraints
// TODO service_registries
resource "aws_ecs_service" "config_service" {
  name            = "${local.prefix}-config-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = "${aws_ecs_task_definition.config_service.family}:${max(aws_ecs_task_definition.config_service.revision, data.aws_ecs_task_definition.config_service.revision)}"

  desired_count                      = 1
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 200
  launch_type                        = "EC2"
  scheduling_strategy                = "REPLICA"
  force_new_deployment               = true

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_config_service.arn
    container_name   = local.config_service_container_name
    container_port   = 3000
  }

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.config_service.id]
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_security_group" "config_service" {
  name   = "${local.prefix}-ecs-config-service"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 3000
    to_port         = 3000
    security_groups = aws_lb.ecs_main.security_groups
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_cloudwatch_log_group" "config_service" {
  name = "/ecs/${local.prefix}-config-service"

  retention_in_days = 7
}
