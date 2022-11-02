resource "aws_iam_role" "lambda" {
  name = var.name

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
}

resource "aws_iam_policy" "lambda" {
  name = "${var.name}-policy"
  policy = var.policy_json
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}

// TODO: do not forget to uncomment!!!!
//resource "aws_lambda_permission" "lambda" {
//  statement_id  = "AllowAPIGatewayInvoke"
//  action        = "lambda:InvokeFunction"
//  function_name = <lambda_function_name>
//  principal     = "apigateway.amazonaws.com"
//
//  source_arn = <api_gateway_arn>
//}