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

output "alb_listener_arn" {
  value = aws_lb_listener.ecs_main_http.arn
}

output "ecs_cluster_id" {
  value = aws_ecs_cluster.main.id
}

output "alb_sg_id" {
  value = aws_security_group.ecs_main_lb.id
}

output "efs_id" {
  value = aws_efs_file_system.libs.id
}

output "efs_sg_access_id" {
  value = aws_security_group.efs_access.id
}
