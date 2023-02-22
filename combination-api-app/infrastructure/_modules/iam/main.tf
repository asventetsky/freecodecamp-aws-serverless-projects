resource "aws_iam_role" "lambda_api_combiner" {
  name = var.lambda_name


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

  tags = var.resource_tags
}

resource "aws_iam_policy" "lambda_api_combiner" {
  name = var.lambda_name
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
      }
    ]
  })

  tags = var.resource_tags
}

resource "aws_iam_role_policy_attachment" "api_composer_lambda" {
  role = aws_iam_role.lambda_api_combiner.name
  policy_arn = aws_iam_policy.lambda_api_combiner.arn
}
