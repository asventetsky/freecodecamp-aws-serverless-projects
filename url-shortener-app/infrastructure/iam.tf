resource "aws_iam_role" "lambda_url_shortener_role" {
  name = "lambda-url-shortener-role"


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

resource "aws_iam_policy" "lambda_url_shortener_policy" {
  name = "lambda-url-shortener-policy"
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
          "dynamodb:PutItem",
          "dynamodb:GetItem"
        ],
        Effect : "Allow",
        Resource : "${aws_dynamodb_table.short_urls.arn}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_url_shortener_lambda" {
  role = aws_iam_role.lambda_url_shortener_role.name
  policy_arn = aws_iam_policy.lambda_url_shortener_policy.arn
}

resource "aws_lambda_permission" "url_shortener_lambda_short_url_create" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_short_url_create.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.url_shortener.execution_arn}/*/*"
}

resource "aws_lambda_permission" "url_shortener_lambda_original_url_get" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_original_url_get.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.url_shortener.execution_arn}/*/*"
}

resource "aws_api_gateway_account" "apigw_account" {
  cloudwatch_role_arn = aws_iam_role.apigw_cloudwatch.arn
}

resource "aws_iam_role" "apigw_cloudwatch" {
  # https://gist.github.com/edonosotti/6e826a70c2712d024b730f61d8b8edfc
  name = "api_gateway_cloudwatch_global"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "apigw_cloudwatch" {
  name = "default"
  role = aws_iam_role.apigw_cloudwatch.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
