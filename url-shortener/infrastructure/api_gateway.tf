resource "aws_api_gateway_rest_api" "short_url" {
  name        = "short-url"
}

resource "aws_api_gateway_resource" "short_url" {
  path_part   = "short-url"
  parent_id   = aws_api_gateway_rest_api.short_url.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.short_url.id
}

resource "aws_api_gateway_stage" "short_url_dev" {
  stage_name = "dev"
  rest_api_id = aws_api_gateway_rest_api.short_url.id
  deployment_id = aws_api_gateway_deployment.short_url.id

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.short_url_gw.arn

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

resource "aws_api_gateway_method" "short_url_create" {
  rest_api_id   = aws_api_gateway_rest_api.short_url.id
  resource_id   = aws_api_gateway_resource.short_url.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration_get" {
  depends_on = [
    aws_lambda_permission.apigw
  ]
  rest_api_id = aws_api_gateway_rest_api.short_url.id
  resource_id = aws_api_gateway_method.short_url_create.resource_id
  http_method = aws_api_gateway_method.short_url_create.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_short_url_create.invoke_arn
}

resource "aws_api_gateway_deployment" "short_url" {
  depends_on = [aws_api_gateway_integration.lambda_integration_get,  aws_api_gateway_method.short_url_create]

  rest_api_id = aws_api_gateway_rest_api.short_url.id
}

resource "aws_cloudwatch_log_group" "short_url_gw" {
  name = "/aws/api-gw/${aws_api_gateway_rest_api.short_url.name}"

  retention_in_days = 1
}
