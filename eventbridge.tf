resource "aws_cloudwatch_event_rule" "route53_events" {
  name = "route53_events"

  description   = "all route53 events"
  event_pattern = <<EOF
{
  "source": [
    "aws.route53"
  ],
  "detail": {
    "errorMessage": [ { "exists": false  } ]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "sqs_queue" {
  rule = aws_cloudwatch_event_rule.route53_events.name

  arn = aws_sqs_queue.route53_events_queue.arn
}