output "config_service_image_url" {
  value = module.ecr_config_service.repository_url
}
output "config_service_repo_name" {
  value = module.ecr_config_service.repository_name
}

output "tmp_service_image_url" {
  value = module.ecr_tmp_service.repository_url
}
output "tmp_service_repo_name" {
  value = module.ecr_tmp_service.repository_name
}
