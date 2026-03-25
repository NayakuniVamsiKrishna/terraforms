# Deploy Lambda function from local zipfile
resource "aws_lambda_function" "local_zipfile" {
  count = var.function_s3_bucket == "" ? 1 : 0

  filename         = var.function_zipfile
  source_code_hash = filebase64sha256(var.function_zipfile)

  description = "${var.comment_prefix}${var.cronjob_name}"
  function_name = local.prefix_with_name
  handler       = var.function_handler
  runtime       = var.function_runtime
  timeout       = var.function_timeout
  memory_size   = var.memory_size
  role          = aws_iam_role.this.arn
  tags          = var.tags

  environment {
    variables = var.function_env_vars
  }
}

# Deploy Lambda function from S3 zipfile
resource "aws_lambda_function" "s3_zipfile" {
  count = var.function_s3_bucket != "" ? 1 : 0

  s3_bucket = var.function_s3_bucket
  s3_key    = var.function_zipfile

  description = "${var.comment_prefix}${var.cronjob_name}"
  function_name = local.prefix_with_name
  handler       = var.function_handler
  runtime       = var.function_runtime
  timeout       = var.function_timeout
  memory_size   = var.memory_size
  role          = aws_iam_role.this.arn
  tags          = var.tags

  environment {
    variables = var.function_env_vars
  }
}

# Select the correct Lambda function based on deployment method
locals {
  function_id         = try(aws_lambda_function.local_zipfile[0].id, aws_lambda_function.s3_zipfile[0].id)
  function_arn        = try(aws_lambda_function.local_zipfile[0].arn, aws_lambda_function.s3_zipfile[0].arn)
  function_invoke_arn = try(aws_lambda_function.local_zipfile[0].invoke_arn, aws_lambda_function.s3_zipfile[0].invoke_arn)
}
