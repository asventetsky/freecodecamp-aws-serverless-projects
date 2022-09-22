resource "aws_iam_role" "api_composer_lambda_role" {
  name = "api-composer-lambda-role"


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

resource "aws_iam_policy" "api_composer_lambda_policy" {
  name = "api-composer-lambda"
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
}

resource "aws_iam_role_policy_attachment" "api_composer_lambda" {
  role = aws_iam_role.api_composer_lambda_role.name
  policy_arn = aws_iam_policy.api_composer_lambda_policy.arn
}

resource "aws_lambda_permission" "api_composer" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_composer.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.api_composer.execution_arn}/*/*"
}
