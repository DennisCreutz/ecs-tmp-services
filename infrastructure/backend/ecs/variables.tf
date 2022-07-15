locals {
  stage      = "prod"
  project    = "ecs-tmp-services"
  prefix_env = terraform.workspace == "default" ? local.stage : terraform.workspace
  prefix     = "${local.project}-${local.prefix_env}"

  config_service_container_name = "${local.prefix}-config-service"

  default_tags = {
    stage        = local.stage
    project      = local.project
    tf_workspace = terraform.workspace
  }
}
