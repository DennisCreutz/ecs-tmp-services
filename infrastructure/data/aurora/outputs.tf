output "public_subnets" {
  value = module.aurora.database_public_subnets
}

output "private_subnets" {
  value = module.aurora.database_private_subnets
}

output "vpc_id" {
  value = module.aurora.database_vpc
}

output "private_route_table_id" {
  value = module.aurora.private_route_table_id
}

output "INFO" {
  value = "Execute 'GRANT INVOKE LAMBDA ON *.* TO user@domain-or-ip-address' on the database!"
}
