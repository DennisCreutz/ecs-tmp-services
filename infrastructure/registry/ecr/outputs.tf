output "order_manager_image_url" {
  value = module.ecr_config_service.repository_url
}

output "order_manager_repo_name" {
  value = module.ecr_config_service.repository_name
}
