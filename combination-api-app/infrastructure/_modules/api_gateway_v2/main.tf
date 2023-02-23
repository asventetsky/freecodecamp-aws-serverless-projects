resource "aws_apigatewayv2_api" "api_combiner" {
  name          = "api-combiner-gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "api_combiner" {
  api_id = aws_apigatewayv2_api.api_combiner.id

  name        = "api-combiner-${var.env}"
  auto_deploy = true

//  access_log_settings {
//    destination_arn = aws_cloudwatch_log_group.api_combiner.arn
//
//    format = jsonencode({
//      requestId               = "$context.requestId"
//      sourceIp                = "$context.identity.sourceIp"
//      requestTime             = "$context.requestTime"
//      protocol                = "$context.protocol"
//      httpMethod              = "$context.httpMethod"
//      resourcePath            = "$context.resourcePath"
//      routeKey                = "$context.routeKey"
//      status                  = "$context.status"
//      responseLength          = "$context.responseLength"
//      integrationErrorMessage = "$context.integrationErrorMessage"
//    }
//    )
//  }
}

resource "aws_apigatewayv2_integration" "api_combiner" {
  api_id = aws_apigatewayv2_api.api_combiner.id

  integration_uri    = var.lambda_invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "api_combiner" {
  api_id = aws_apigatewayv2_api.api_combiner.id

  route_key = "GET /jokes"
  target    = "integrations/${aws_apigatewayv2_integration.api_combiner.id}"
}

resource "aws_cloudwatch_log_group" "api_combiner" {
  name = "/aws/api-gw/${aws_apigatewayv2_api.api_combiner.name}"

  retention_in_days = 1
}

resource "aws_lambda_permission" "api_combiner" {
  statement_id  = "AllowLambdaExecution"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.api_combiner.execution_arn}/*/*"
}
