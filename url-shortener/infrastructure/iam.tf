resource "aws_iam_role" "lambda_short_url_role" {
  name = "lambda-short-url-role"


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

  tags = {
    "Terraform" = "true"
  }
}

resource "aws_iam_policy" "lambda_short_url_policy" {
  name = "lambda-short-url-policy"
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
        Action : "dynamodb:PutItem",
        Effect : "Allow",
        Resource : "${aws_dynamodb_table.short_urls.arn}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_short_url_lambda" {
  role = aws_iam_role.lambda_short_url_role.name
  policy_arn = aws_iam_policy.lambda_short_url_policy.arn
}
