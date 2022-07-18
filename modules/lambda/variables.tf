variable "region" {
  description = "Name of the current region."
  type        = string
  default     = "eu-central-1"
}

variable "stage" {
  description = "Name of the stage."
  type        = string
}

variable "project" {
  description = "Project name."
  type        = string
}

variable "lambda_name" {
  description = "Name of the lambda function."
  type        = string
}

variable "source_dir" {
  description = "Source dir of the Lambda code."
  type        = string
}

variable "log_retention" {
  description = "Lambda log retention in days."
  type        = number
  default     = 7
}

variable "create_version" {
  description = "Create a Lambda version on change?"
  type        = bool
  default     = true
}

variable "memory_size" {
  description = "Maximum memory size of the Lambda function."
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Timeout in seconds of the Lambda function."
  type        = number
  default     = 3
}

variable "runtime" {
  description = "Runtime of the Lambda function."
  type        = string
  default     = "nodejs14.x"
}

variable "architectures" {
  description = "Lambda architectures. Valid values are [\"x86_64\"] and [\"arm64\"]"
  type        = list(string)
  default     = ["arm64"]
}

variable "additional_lambda_policy" {
  description = "Additional permissions for the Lambda function, as policy document."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "List of subnet ID's to deploy the Lambda function."
  type        = list(string)
  default     = []
}

variable "default_security_group_id" {
  description = "Default security group ID of the VPC"
  type        = list(string)
  default     = []
}

variable "keep_warm" {
  description = "Keeps the Lambda warm and prevents cold starts."
  type        = bool
  default     = false
}

variable "keep_warm_options" {
  description = "Options for the Lambda warmer."
  type = object({
    rate  = string
    input = string
  })
  default = null
}

variable "security_group_configuration" {
  description = "Security group configuration for the Lambda function."
  type = object({
    vpc_id = string
    ingress = object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    })
    egress = object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    })
  })
  default = null
}

variable "lambda_layers" {
  description = "Layers that are used by the Lambda function"
  type        = list(string)
  default     = []
}

variable "environment_variables" {
  description = "Environment variables."
  type = list(object({
    variables = map(string)
  }))
  default = []
}

variable "enable_xray" {
  description = "Enable Xray tracing."
  type        = bool
  default     = false
}

locals {
  lambda_file = "${var.source_dir}/${var.lambda_name}.lambda.zip"
  prefix_env  = terraform.workspace == "default" ? var.stage : terraform.workspace
  prefix      = "${var.project}-${local.prefix_env}"
}
