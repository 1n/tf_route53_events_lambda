output "lambda_cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.lambda_logs.arn
}