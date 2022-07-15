output "lb_dns" {
  value = aws_lb.ecs_main.dns_name
}
