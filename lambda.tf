locals {
  lambda_function_name = "sqs-to-cwlogs-lambda"
  lambda_package_path  = "${path.module}/lambda/package/lambda.zip"
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

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

data "aws_iam_policy_document" "lambda_sqs_policy" {
  statement {
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]

    resources = [
      aws_sqs_queue.route53_events_queue.arn
    ]
  }
}

resource "aws_iam_policy" "lambda_sqs_policy" {
  name        = "lambda_sqs"
  path        = "/"
  description = "lambda sqs policy"

  policy = data.aws_iam_policy_document.lambda_sqs_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_sqs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_sqs_policy.arn
}

resource "aws_lambda_event_source_mapping" "sqs" {
  event_source_arn = aws_sqs_queue.route53_events_queue.arn
  function_name    = aws_lambda_function.sqs_to_cwlogs_lambda.arn
}

resource "aws_lambda_function" "sqs_to_cwlogs_lambda" {
  filename      = local.lambda_package_path
  function_name = local.lambda_function_name
  role          = aws_iam_role.lambda_role.arn
  handler       = "main"

  source_code_hash = data.archive_file.lambda_package.output_base64sha256

  runtime = "go1.x"

  environment {
    variables = {
      AUTHOR = var.author
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.lambda_logs,
  ]
}