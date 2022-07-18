output "cluster_id" {
  value = module.aurora_mysql_serverless.rds_cluster_id
}

output "current_region_name" {
  value = data.aws_region.current.name
}

output "database_vpc" {
  value = aws_vpc.database.id
}

output "default_security_group_id" {
  description = "The security group ID of the cluster"
  value       = aws_vpc.database.default_security_group_id
}

output "database_public_subnets" {
  value = aws_subnet.public_subnets
}

output "database_private_subnets" {
  value = aws_subnet.private_subnets
}

output "cluster_arn" {
  value = module.aurora_mysql_serverless.rds_cluster_arn
}

output "cluster_endpoint" {
  value = module.aurora_mysql_serverless.rds_cluster_endpoint
}

output "default_db_name" {
  value = module.aurora_mysql_serverless.rds_cluster_database_name
}

output "cluster_username" {
  value     = module.aurora_mysql_serverless.rds_cluster_master_username
  sensitive = true
}

output "cluster_password" {
  value     = module.aurora_mysql_serverless.rds_cluster_master_password
  sensitive = true
}

output "ssm_path_root_username" {
  value     = aws_ssm_parameter.ssm_root_user_name.name
  sensitive = true
}

output "ssm_path_root_password" {
  value     = aws_ssm_parameter.ssm_root_user_pw.name
  sensitive = true
}

output "ssm_path_tech_username" {
  value     = aws_ssm_parameter.ssm_tech_user_name.name
  sensitive = true
}

output "ssm_path_tech_password" {
  value     = aws_ssm_parameter.ssm_tech_user_pw.name
  sensitive = true
}

output "ssm_path_tech_ro_username" {
  value     = aws_ssm_parameter.ssm_tech_ro_user_name.name
  sensitive = true
}

output "ssm_path_tech_ro_password" {
  value     = aws_ssm_parameter.ssm_tech_ro_user_pw.name
  sensitive = true
}

output "ssm_path_admin_users" {
  value     = local.ssm_path_admin_users
  sensitive = true
}

output "ssm_path_restricted_admin_users" {
  value     = local.ssm_path_restricted_admin_users
  sensitive = true
}

output "ssm_path_readonly_users" {
  value     = local.ssm_path_readonly_users
  sensitive = true
}
