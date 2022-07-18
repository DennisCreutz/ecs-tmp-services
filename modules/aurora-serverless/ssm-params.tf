resource "aws_ssm_parameter" "ssm_tech_user_name" {
  name        = local.ssm_path_tech_user_name
  description = "Basic auth username for Aurora mysql project ${var.project} stage ${var.stage} and tf workspace ${terraform.workspace}"
  type        = "SecureString"
  value       = random_string.ssm_tech_user_name.result
  overwrite   = true

  tags = local.default_tags
}

resource "aws_ssm_parameter" "ssm_tech_user_pw" {
  name        = local.ssm_path_tech_user_pw
  description = "Basic auth password for Aurora mysql project ${var.project} stage ${var.stage} and tf workspace ${terraform.workspace}"
  type        = "SecureString"
  value       = random_password.ssm_tech_user_pwd.result
  overwrite   = true

  tags = local.default_tags
}

resource "aws_ssm_parameter" "ssm_tech_ro_user_name" {
  name        = local.ssm_path_tech_ro_user_name
  description = "Basic auth username for Aurora mysql project ${var.project} stage ${var.stage} and tf workspace ${terraform.workspace}"
  type        = "SecureString"
  value       = random_string.ssm_tech_ro_user_name.result
  overwrite   = true

  tags = local.default_tags
}

resource "aws_ssm_parameter" "ssm_tech_ro_user_pw" {
  name        = local.ssm_path_tech_ro_user_pw
  description = "Basic auth password for Aurora mysql project ${var.project} stage ${var.stage} and tf workspace ${terraform.workspace}"
  type        = "SecureString"
  value       = random_password.ssm_tech_ro_user_pwd.result
  overwrite   = true

  tags = local.default_tags
}

resource "aws_ssm_parameter" "ssm_root_user_name" {
  name        = local.ssm_path_root_user_name
  description = "Root auth username for Aurora mysql project ${var.project} stage ${var.stage} and tf workspace ${terraform.workspace}"
  type        = "SecureString"
  value       = module.aurora_mysql_serverless.rds_cluster_master_username
  overwrite   = true

  tags = local.default_tags
}

resource "aws_ssm_parameter" "ssm_root_user_pw" {
  name        = local.ssm_path_root_user_pw
  description = "Root auth password for Aurora mysql project ${var.project} stage ${var.stage} and tf workspace ${terraform.workspace}"
  type        = "SecureString"
  value       = module.aurora_mysql_serverless.rds_cluster_master_password
  overwrite   = true

  tags = local.default_tags
}

resource "random_string" "ssm_tech_user_name" {
  length           = 6
  special          = false
  override_special = "/@£$"
}

resource "random_password" "ssm_tech_user_pwd" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "random_string" "ssm_tech_ro_user_name" {
  length           = 6
  special          = false
  override_special = "/@£$"
}

resource "random_password" "ssm_tech_ro_user_pwd" {
  length           = 16
  special          = true
  override_special = "_%@"
}