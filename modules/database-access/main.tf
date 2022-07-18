data "aws_region" "current" {}

module "bastion" {
  source  = "Guimove/bastion/aws"
  version = "v3.0.2"

  bucket_name = "${local.prefix}-bastion-ssh"

  vpc_id                = var.vpc_id
  is_lb_private         = false
  bastion_host_key_pair = var.bastion_host_key_pair
  region                = data.aws_region.current.name

  create_dns_record   = var.bastion_record_name != null
  hosted_zone_id      = var.dns_hosted_zone != null ? var.dns_hosted_zone : null
  bastion_record_name = var.bastion_record_name != null ? var.bastion_record_name : null

  bastion_iam_policy_name      = "${local.prefix}-bastion"
  bastion_launch_template_name = "${local.prefix}-bastion"

  associate_public_ip_address = true
  elb_subnets                 = var.lb_subnet_ids
  auto_scaling_group_subnets  = var.bastion_subnet_ids

  bastion_instance_count = var.bastion_instance_count
  instance_type          = var.bastion_host_instance_type

  log_auto_clean  = true
  log_expiry_days = var.log_expiry_days

  allow_ssh_commands = var.allow_ssh_commands

  tags = local.default_tags
}
