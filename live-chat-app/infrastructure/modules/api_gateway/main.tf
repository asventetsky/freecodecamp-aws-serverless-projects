resource "aws_apigatewayv2_api" "live_chat" {
  name                       = "live-chat-api"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}

module "api_gateway_route_connect" {
  source = "../api_gateway_route"

  api_gateway_id = aws_apigatewayv2_api.live_chat.id
  api_gateway_execution_arn = aws_apigatewayv2_api.live_chat.execution_arn

  route_key = "$connect"

  lambda_invoke_arn = var.lambda_connect_invoke_arn
  lambda_name = var.lambda_connect_name
  
}

module "api_gateway_route_create_room" {
  source = "../api_gateway_route"

  api_gateway_id = aws_apigatewayv2_api.live_chat.id
  api_gateway_execution_arn = aws_apigatewayv2_api.live_chat.execution_arn

  route_key = "create_room"

  lambda_invoke_arn = var.lambda_create_room_invoke_arn
  lambda_name = var.lambda_create_room_name
}

resource "aws_apigatewayv2_deployment" "live_chat" {
  depends_on = [
    module.api_gateway_route_connect,
    module.api_gateway_route_create_room
  ]
  api_id      = aws_apigatewayv2_api.live_chat.id

  lifecycle {
    create_before_destroy = true
  }
}

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
