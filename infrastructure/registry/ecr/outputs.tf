output "config_service_image_url" {
  value = module.ecr_config_service.repository_url
}

output "config_service_repo_name" {
  value = module.ecr_config_service.repository_name
}
