resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${local.lambda_function_name}"
  retention_in_days = 1
}

data "aws_iam_policy_document" "lambda_log_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "${aws_cloudwatch_log_group.lambda_logs.arn}:*"
    ]
  }
}

resource "aws_iam_policy" "lambda_log_policy" {
  name        = "lambda_logging"
  path        = "/"
  description = "lambda logging policy"

  policy = data.aws_iam_policy_document.lambda_log_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_log_policy.arn
}