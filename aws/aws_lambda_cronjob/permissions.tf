# Lambda execution role
resource "aws_iam_role" "this" {
  name = local.prefix_with_name
  tags = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Allow writing logs to CloudWatch
resource "aws_iam_policy" "logging" {
  count = var.lambda_logging_enabled ? 1 : 0
  name  = "${local.prefix_with_name}-logging"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
        Effect   = "Allow"
      }
    ]
  })
}

# Attach logging policy to role
resource "aws_iam_role_policy_attachment" "logging" {
  count      = var.lambda_logging_enabled ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.logging[0].arn
}

# CloudWatch Event Rule for scheduled invocation
resource "aws_cloudwatch_event_rule" "this" {
  name                = "${local.prefix_with_name}---scheduled-invocation"
  schedule_expression = var.schedule_expression
  tags                = var.tags
}

# Target Lambda function for the scheduled event
resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.this.name
  target_id = aws_cloudwatch_event_rule.this.name
  arn       = local.function_arn
}

# Allow CloudWatch Events to invoke Lambda
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "${local.prefix_with_name}---scheduled-invocation"
  action        = "lambda:InvokeFunction"
  function_name = local.function_id
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this.arn
}
