resource "aws_apigatewayv2_api" "live_chat" {
  name                       = "live-chat-api"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}

resource "aws_apigatewayv2_route" "live_chat_connect" {
  api_id    = aws_apigatewayv2_api.live_chat.id
  route_key = "$connect"

  target = "integrations/${aws_apigatewayv2_integration.live_chat_connect.id}"
}

resource "aws_apigatewayv2_integration" "live_chat_connect" {
  api_id           = aws_apigatewayv2_api.live_chat.id
  integration_type = "AWS_PROXY"

  content_handling_strategy = "CONVERT_TO_TEXT"
  integration_method        = "POST"
  integration_uri           = var.lambda_connect_invoke_arn
  passthrough_behavior      = "WHEN_NO_MATCH"
}

resource "aws_lambda_permission" "lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_connect_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.live_chat.execution_arn}/*/$connect"
}

//resource "aws_apigatewayv2_deployment" "live_chat" {
//  depends_on = [
//
//  ]
//  api_id      = aws_apigatewayv2_api.live_chat.id
//
//  lifecycle {
//    create_before_destroy = true
//  }
//}

resource "aws_apigatewayv2_stage" "live_chat_dev" {
  api_id = aws_apigatewayv2_api.live_chat.id
  name   = "dev"

  default_route_settings {
    throttling_burst_limit = 100
    throttling_rate_limit = 100
  }

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.live_chat_gw.arn

    format = jsonencode({
      requestId = "$context.requestId"
      sourceIp = "$context.identity.sourceIp"
      requestTime = "$context.requestTime"
      protocol = "$context.protocol"
      httpMethod = "$context.httpMethod"
      resourcePath = "$context.resourcePath"
      routeKey = "$context.routeKey"
      status = "$context.status"
      responseLength = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
    }
    )
  }
}

resource "aws_cloudwatch_log_group" "live_chat_gw" {
  name = "/aws/api-gw/${aws_apigatewayv2_api.live_chat.name}"

  retention_in_days = 1
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
