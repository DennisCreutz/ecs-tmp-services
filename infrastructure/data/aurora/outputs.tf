output "public_subnets" {
  value = module.aurora_serverless.database_public_subnets
}

output "private_subnets" {
  value = module.aurora_serverless.database_private_subnets
}

output "vpc_id" {
  value = module.aurora_serverless.database_vpc
}
