output "function_name" {
  description = "The name of the Lambda function that was created"
  value       = local.function_id
}

output "function_arn" {
  description = "The ARN of the Lambda function"
  value       = local.function_arn
}

output "role_arn" {
  description = "The ARN of the IAM role for the Lambda function"
  value       = aws_iam_role.this.arn
}

output "schedule_expression" {
  description = "The schedule expression used to trigger the Lambda function"
  value       = var.schedule_expression
}
