output "alb" {
  value = aws_lb.ecs_main
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "private_subnets_cidr_blocks" {
  value = module.vpc.private_subnets_cidr_blocks
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_route_table_ids" {
  value = module.vpc.private_route_table_ids
}

output "config_service_security_group_id" {
  value = aws_security_group.config_service.id
}
