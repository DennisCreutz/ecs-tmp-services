variable "stage" {
  description = "The name of the stage."
  type        = string
}

variable "project" {
  description = "Project name."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC to create the Bastion host security group."
  type        = string
}

variable "bastion_subnet_ids" {
  description = "List of subnet IDs to place the bastion instances."
  type        = list(string)
}

variable "lb_subnet_ids" {
  description = "List of subnet IDs to place the load balancer."
  type        = list(string)
}

variable "bastion_host_key_pair" {
  description = "The host key pair name used with the created bastion hosts. Must be created outside of Terraform."
  type        = string
}

variable "bastion_host_instance_type" {
  description = "The instance type of the bastion host."
  type        = string
  default     = "t2.micro"
}

variable "bastion_instance_count" {
  description = "Number of bastion host instances."
  type        = number
  default     = 1
}

variable "allow_ssh_commands" {
  description = "Allows the SSH user to execute one-off commands. Pass true to enable. Warning: These commands are not logged and increase the vulnerability of the system. Use at your own discretion."
  type        = bool
  default     = false
}

variable "dns_hosted_zone" {
  description = "ID of the Route53 hosted zone."
  type        = string
  default     = null
}

variable "bastion_record_name" {
  description = "DNS record for the bastion hosts."
  type        = string
  default     = null
}

variable "log_expiry_days" {
  description = "Days till the logs will be deleted from the S3 bucket. Must be over 60 days."
  type        = number
  default     = 365
}

locals {
  prefix_env = terraform.workspace == "default" ? var.stage : terraform.workspace
  prefix     = "${var.project}-${local.prefix_env}"
  default_tags = {
    stage        = var.stage
    project      = var.project
    tf_workspace = terraform.workspace
  }
}
