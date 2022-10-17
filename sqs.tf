data "aws_iam_policy_document" "eventbridge_sqs_policy" {
  statement {
    actions = [
      "sqs:SendMessage"
    ]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    resources = [
      aws_sqs_queue.route53_events_queue.arn,
    ]
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"

      values = [
        aws_cloudwatch_event_rule.route53_events.arn
      ]
    }
  }
}

resource "aws_sqs_queue_policy" "eventbridge_sqs_policy" {
  queue_url = aws_sqs_queue.route53_events_queue.id

  policy = data.aws_iam_policy_document.eventbridge_sqs_policy.json
}

resource "aws_sqs_queue" "route53_events_queue" {
  name = "route53_events_queue"

  sqs_managed_sse_enabled = true
}