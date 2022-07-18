resource "aws_iam_role" "this" {
  name = "${local.prefix}-${var.lambda_name}-iam-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "${local.prefix}-${var.lambda_name}-logging-policy"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}


resource "aws_iam_policy" "lambda_xray" {
  name        = "${local.prefix}-${var.lambda_name}-xray-policy"
  path        = "/"
  description = "IAM policy for Xray from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_eni" {
  name        = "${local.prefix}-${var.lambda_name}-eni-policy"
  path        = "/"
  description = "IAM policy for creating ENI's from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:DescribeNetworkInterfaces",
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}
resource "aws_iam_role_policy_attachment" "lambda_eni" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.lambda_eni.arn
}
resource "aws_iam_role_policy_attachment" "lambda_xray" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.lambda_xray.arn
}

resource "aws_iam_policy" "additional_policy" {
  count = var.additional_lambda_policy == null ? 0 : 1

  name        = "${local.prefix}-${var.lambda_name}-ap"
  path        = "/"
  description = "IAM policy for additional permissions for a Lambda function."

  policy = var.additional_lambda_policy
}
resource "aws_iam_role_policy_attachment" "additional_permissions" {
  count = var.additional_lambda_policy == null ? 0 : 1

  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.additional_policy[0].arn
}

data "archive_file" "lambda_app" {
  type        = "zip"
  output_path = local.lambda_file
  source_dir  = var.source_dir

  output_file_mode = "0666"

  excludes = [
    "package.json",
    "package-lock.json",
    "${var.lambda_name}.lambda.zip",
    "test-event-input.json",
    ".terragrunt-module-manifest"
  ]
}

resource "aws_security_group" "lambda_sg" {
  count = var.security_group_configuration != null ? 1 : 0

  name        = "${local.prefix}-${var.lambda_name}-sg-${count.index}"
  description = "SG for the ${var.lambda_name} Lambda function."

  vpc_id = var.security_group_configuration.vpc_id
}

resource "aws_security_group_rule" "lambda_sgr_ingress" {
  count = var.security_group_configuration != null ? 1 : 0

  security_group_id = aws_security_group.lambda_sg[0].id
  type              = "ingress"
  from_port         = var.security_group_configuration.ingress.from_port
  to_port           = var.security_group_configuration.ingress.to_port
  protocol          = var.security_group_configuration.ingress.protocol
  cidr_blocks       = var.security_group_configuration.ingress.cidr_blocks
}

resource "aws_security_group_rule" "lambda_sgr_egress" {
  count = var.security_group_configuration != null ? 1 : 0

  security_group_id = aws_security_group.lambda_sg[0].id
  type              = "egress"
  from_port         = var.security_group_configuration.ingress.from_port
  to_port           = var.security_group_configuration.ingress.to_port
  protocol          = var.security_group_configuration.ingress.protocol
  cidr_blocks       = var.security_group_configuration.ingress.cidr_blocks
}

resource "aws_lambda_function" "this" {
  architectures    = var.architectures
  filename         = local.lambda_file
  function_name    = "${local.prefix}-${var.lambda_name}"
  source_code_hash = filebase64sha256(data.archive_file.lambda_app.output_path)
  role             = aws_iam_role.this.arn
  handler          = "${var.lambda_name}.handler"
  runtime          = var.runtime
  memory_size      = var.memory_size
  publish          = var.create_version
  timeout          = var.timeout
  layers           = var.lambda_layers

  dynamic "vpc_config" {
    for_each = length(var.subnet_ids) > 0 && var.security_group_configuration != null ? [1] : []

    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = [aws_security_group.lambda_sg[0].id]
    }
  }

  dynamic "environment" {
    for_each = var.environment_variables

    content {
      variables = environment.value.variables
    }
  }

  tracing_config {
    mode = var.enable_xray ? "Active" : "PassThrough"
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_logs, aws_cloudwatch_log_group.this]
}

resource "aws_cloudwatch_log_group" "this" {
  name = "/aws/lambda/${local.prefix}-${var.lambda_name}"

  retention_in_days = var.log_retention
}
