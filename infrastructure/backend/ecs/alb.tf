resource "aws_lb" "ecs_main" {
  name = "${local.prefix}-ecs-main"

  load_balancer_type = "application"
  internal           = false

  security_groups = [aws_security_group.ecs_main_lb.id]
  subnets         = module.vpc.public_subnets
}

resource "aws_lb_listener" "ecs_main_http" {
  load_balancer_arn = aws_lb.ecs_main.arn

  port     = "80"
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_config_service.arn
  }
}

resource "aws_lb_target_group" "ecs_config_service" {
  name = "${local.prefix}-ecs-cf"

  target_type = "ip"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id

  deregistration_delay = "10"

  health_check {
    enabled             = true
    interval            = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 4
  }
}

resource "aws_security_group" "ecs_main_lb" {
  name   = "${local.prefix}-ecs-main-lb"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
