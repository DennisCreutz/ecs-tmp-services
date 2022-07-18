output "name_servers" {
  value = aws_route53_zone.ecs_tmp_service.name_servers
}

output "zone_id" {
  value = aws_route53_zone.ecs_tmp_service.zone_id
}

output "name" {
  value = aws_route53_zone.ecs_tmp_service.name
}
