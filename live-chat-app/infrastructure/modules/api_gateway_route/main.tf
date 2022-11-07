resource "aws_apigatewayv2_route" "live_chat" {
  api_id    = var.api_gateway_id
  route_key = var.route_key

  target = "integrations/${aws_apigatewayv2_integration.live_chat.id}"
}

resource "aws_apigatewayv2_integration" "live_chat" {
  api_id           = var.api_gateway_id
  integration_type = "AWS_PROXY"

  content_handling_strategy = "CONVERT_TO_TEXT"
  integration_method        = "POST"
  integration_uri           = var.lambda_invoke_arn
  passthrough_behavior      = "WHEN_NO_MATCH"
}

resource "aws_lambda_permission" "lambda" {
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${var.api_gateway_execution_arn}/*/${aws_apigatewayv2_route.live_chat.route_key}"
}