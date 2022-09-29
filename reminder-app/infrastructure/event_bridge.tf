resource "aws_cloudwatch_event_bus" "reminders_events" {
  name = "reminders-events"
}

resource "aws_cloudwatch_event_rule" "reminders_events" {
  name = "reminders-events-rule"
  description = "Reminders Events rule"
  event_bus_name = aws_cloudwatch_event_bus.reminders_events.name
  event_pattern = <<EOF
{
  "source": ["lambda-reminder-event-create"],
  "detail-type": ["reminder-event-create"],
  "detail": {
    "username": [ { "exists": true } ],
    "city": [ { "exists": true } ],
    "age": [ { "exists": true } ]
  }
}
EOF

  tags = local.tags
}

resource "aws_cloudwatch_event_target" "reminders_events" {
  depends_on = [
    aws_cloudwatch_event_rule.reminders_events
  ]
  event_bus_name = aws_cloudwatch_event_bus.reminders_events.name
  rule = aws_cloudwatch_event_rule.reminders_events.name
  arn = aws_lambda_function.lambda_reminder_send.arn
}
