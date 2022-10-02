// ============================
// lambda-reminder-event-create
// ============================
resource "aws_iam_role" "lambda_reminder_event_create_role" {
  name = "lambda-reminder-event-create-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = local.tags
}

resource "aws_iam_policy" "lambda_reminder_event_create_policy" {
  name = "lambda-reminder-event-create-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect : "Allow",
        Resource : "arn:aws:logs:*:*:*"
      },
      {
        Action : [
          "events:PutRule",
          "events:PutEvents",
          "events:PutTargets"
        ],
        Effect : "Allow",
        Resource : "*"
      },
      {
        Action : [
          "lambda:AddPermission"
        ],
        Effect : "Allow",
        Resource : aws_lambda_function.lambda_reminder_send.arn
      },
      {
        Action: [
          "dynamodb:GetRecords",
          "dynamodb:GetShardIterator",
          "dynamodb:DescribeStream",
          "dynamodb:ListStreams"
        ],
        Effect: "Allow",
        Resource: [
          aws_dynamodb_table.reminders.arn,
          "${aws_dynamodb_table.reminders.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_url_shortener_lambda" {
  role = aws_iam_role.lambda_reminder_event_create_role.name
  policy_arn = aws_iam_policy.lambda_reminder_event_create_policy.arn
}

// ============================
// lambda-reminder-send
// ============================
resource "aws_iam_role" "lambda_reminder_send_role" {
  name = "lambda-reminder-send-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = local.tags
}

resource "aws_iam_policy" "lambda_reminder_send_policy" {
  name = "lambda-reminder-send-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect : "Allow",
        Resource : "arn:aws:logs:*:*:*"
      },
      {
        Action : [
          "ses:SendEmail"
        ],
        Effect : "Allow",
        Resource : "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_reminder_send" {
  role = aws_iam_role.lambda_reminder_send_role.name
  policy_arn = aws_iam_policy.lambda_reminder_send_policy.arn
}

//resource "aws_lambda_permission" "allow_lambda_reminder_send_by_event_bridge" {
//  action = "lambda:InvokeFunction"
//  function_name = aws_lambda_function.lambda_reminder_send.function_name
//  principal = "events.amazonaws.com"
//  source_arn = aws_cloudwatch_event_rule.reminders_events.arn
//}
