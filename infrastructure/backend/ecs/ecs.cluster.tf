data "aws_ami" "aws_optimized_ecs" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.*-x86_64-ebs"]
  }
}

data "aws_iam_policy_document" "ecs_worker" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_ecs_cluster" "main" {
  name = "${local.prefix}-ecs"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  depends_on = [aws_cloudwatch_log_group.config_service]
}
resource "aws_ecs_account_setting_default" "container_insights" {
  name  = "containerInsights"
  value = "enabled"

  depends_on = [aws_ecs_cluster.main]
}
resource "aws_ecs_account_setting_default" "awsvpc_trunking" {
  name  = "awsvpcTrunking"
  value = "enabled"

  depends_on = [aws_ecs_cluster.main]
}

resource "aws_iam_role" "ecs_worker" {
  name               = "${local.prefix}-ecs-worker"
  assume_role_policy = data.aws_iam_policy_document.ecs_worker.json
}


resource "aws_iam_role_policy_attachment" "ecs_worker" {
  role       = aws_iam_role.ecs_worker.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_worker" {
  name = "${local.prefix}-ecs-worker"
  role = aws_iam_role.ecs_worker.name
}

resource "aws_security_group" "ecs_worker" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "ecs_worker" {
  image_id             = data.aws_ami.aws_optimized_ecs.id
  iam_instance_profile = aws_iam_instance_profile.ecs_worker.name
  security_groups      = [aws_security_group.ecs_worker.id]
  instance_type        = "t3.medium"
  user_data            = "#!/bin/bash\necho ECS_CLUSTER=${aws_ecs_cluster.main.name} > /etc/ecs/ecs.config"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs_worker" {
  name                 = "${local.prefix}-ecs-worker"
  vpc_zone_identifier  = module.vpc.private_subnets
  launch_configuration = aws_launch_configuration.ecs_worker.name

  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = [aws_ecs_capacity_provider.ec2_main.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ec2_main.name
  }
}


resource "aws_ecs_capacity_provider" "ec2_main" {
  /*
   Up to 255 characters are allowed, including letters (upper and lowercase), numbers, underscores, and hyphens.
   The name cannot be prefixed with "aws", "ecs", or "fargate".
  */
  name = "_${local.prefix}-ec2-main"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_worker.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 3
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
      instance_warmup_period    = 60
    }
  }
}
