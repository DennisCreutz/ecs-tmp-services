output "lb_dns" {
  value = aws_lb.ecs_main.dns_name
}

output "public_subnets" {
  value = module.vpc.public_subnets
}
