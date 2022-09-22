resource "aws_apigatewayv2_api" "api_composer" {
  name          = "api-composer-gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "api_composer" {
  api_id = aws_apigatewayv2_api.api_composer.id

  name        = "api_composer_dev"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_composer_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "api_composer" {
  api_id = aws_apigatewayv2_api.api_composer.id

  integration_uri    = aws_lambda_function.api_composer.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "api_composer" {
  api_id = aws_apigatewayv2_api.api_composer.id

  route_key = "GET /jokes"
  target    = "integrations/${aws_apigatewayv2_integration.api_composer.id}"
}

resource "aws_cloudwatch_log_group" "api_composer_gw" {
  name = "/aws/api-gw/${aws_apigatewayv2_api.api_composer.name}"

  retention_in_days = 1
}
