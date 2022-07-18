resource "aws_cloudwatch_event_rule" "this" {
  count = var.keep_warm == true ? 1 : 0

  name                = "${local.prefix}-${var.lambda_name}-warmer"
  description         = "Keeps ${var.lambda_name} warm"
  schedule_expression = var.keep_warm_options.rate

  depends_on = [aws_lambda_function.this]
}

resource "aws_cloudwatch_event_target" "this" {
  count = var.keep_warm == true ? 1 : 0

  rule      = aws_cloudwatch_event_rule.this[0].name
  target_id = aws_lambda_function.this.function_name
  arn       = aws_lambda_function.this.arn
  input_transformer {
    input_template = var.keep_warm_options.input
  }
}

resource "aws_lambda_permission" "this" {
  count = var.keep_warm == true ? 1 : 0

  statement_id  = "${local.prefix}-${var.lambda_name}-AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this[0].arn
}


resource "aws_iam_policy" "lambda_warmer" {
  count = var.keep_warm == true ? 1 : 0

  name        = "${local.prefix}-${var.lambda_name}-warmer-policy"
  path        = "/"
  description = "Keeps ${var.lambda_name} warm"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": "${aws_lambda_function.this.arn}*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_warmer" {
  count = var.keep_warm == true ? 1 : 0

  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.lambda_warmer[0].arn
}

