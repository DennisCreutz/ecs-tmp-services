module "aurora_mysql" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 7.2"

  name           = local.aurora_name
  engine         = "aurora-mysql"
  engine_version = var.database_engine_version

  instances = var.instances

  storage_encrypted = true

  master_username        = var.username
  create_random_password = var.password == ""
  master_password        = var.password == "" ? null : var.password
  iam_roles              = var.iam_roles

  vpc_id                      = aws_vpc.database.id
  subnets                     = aws_subnet.private_subnets.*.id
  create_security_group       = true
  security_group_egress_rules = var.security_group_egress_rules
  allowed_cidr_blocks         = length(var.allowed_cidr_blocks) == 0 ? [aws_vpc.database.cidr_block] : var.allowed_cidr_blocks
  allowed_security_groups = var.allowed_security_groups

  apply_immediately   = var.apply_immediately
  skip_final_snapshot = var.skip_final_snapshot

  db_parameter_group_name         = aws_db_parameter_group.aurora_mysql.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_mysql.id

  scaling_configuration = var.scaling_configuration

  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
  preferred_backup_window = var.preferred_backup_window

  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  copy_tags_to_snapshot = true
  tags                  = local.default_tags

  depends_on = [aws_cloudwatch_log_group.audit, aws_cloudwatch_log_group.error, aws_cloudwatch_log_group.general, aws_cloudwatch_log_group.slow]
}

resource "aws_db_parameter_group" "aurora_mysql" {
  name        = "${local.aurora_name}-db-pg"
  family      = "aurora-mysql5.7"
  description = "Database parameter group for the ${var.aurora_name} Aurora. Project: ${var.project} Stage: ${var.stage}"
  tags        = local.default_tags
}


resource "aws_rds_cluster_parameter_group" "aurora_mysql" {
  name        = "${local.aurora_name}-cluster-pg"
  family      = "aurora-mysql5.7"
  description = "Cluster parameter group for the ${var.aurora_name} Aurora. Project: ${var.project} Stage: ${var.stage}"

  dynamic "parameter" {
    for_each = var.advanced_log_configuration.enable_general_log ? [1] : []

    content {
      name  = "general_log"
      value = "1"
    }
  }

  dynamic "parameter" {
    for_each = var.advanced_log_configuration.enable_slow_query_log ? [1] : []

    content {
      name  = "slow_query_log"
      value = "1"
    }
  }

  dynamic "parameter" {
    for_each = var.advanced_log_configuration.enable_audit_log ? [1] : []

    content {
      name  = "server_audit_logging"
      value = "1"
    }
  }

  dynamic "parameter" {
    for_each = var.advanced_log_configuration.audit_log_events != null ? [1] : []

    content {
      name  = "server_audit_events"
      value = var.advanced_log_configuration.audit_log_events
    }
  }

  dynamic "parameter" {
    for_each = var.aws_default_lambda_role != null ? [1] : []

    content {
      name  = "aws_default_lambda_role"
      value = var.aws_default_lambda_role
    }
  }

  tags = local.default_tags
}

resource "aws_cloudwatch_log_group" "error" {
  name = "/aws/rds/cluster/${local.aurora_name}/error"

  retention_in_days = var.advanced_log_configuration.error_log_retention
}

resource "aws_cloudwatch_log_group" "general" {
  count = var.advanced_log_configuration.enable_general_log == true ? 1 : 0

  name = "/aws/rds/cluster/${local.aurora_name}/general"

  retention_in_days = var.advanced_log_configuration.general_log_retention
}

resource "aws_cloudwatch_log_group" "slow" {
  count = var.advanced_log_configuration.enable_slow_query_log == true ? 1 : 0

  name = "/aws/rds/cluster/${local.aurora_name}/slowquery"

  retention_in_days = var.advanced_log_configuration.slow_query_log_retention
}

resource "aws_cloudwatch_log_group" "audit" {
  count = var.advanced_log_configuration.enable_audit_log == true ? 1 : 0

  name = "/aws/rds/cluster/${local.aurora_name}/audit"

  retention_in_days = var.advanced_log_configuration.audit_log_retention
}
