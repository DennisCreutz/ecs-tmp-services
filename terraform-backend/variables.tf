locals {
  stage      = "global"
  project    = "ecs-tmp-services"
  prefix_env = terraform.workspace == "default" ? local.stage : terraform.workspace
  prefix     = "${local.project}-${local.prefix_env}"
}
