resource "aws_api_gateway_rest_api" "url_shortener" {
  name = "short-url"
}

// ================
// create short url
// ================
resource "aws_api_gateway_resource" "short_url" {
  path_part = "short-url"
  parent_id = aws_api_gateway_rest_api.url_shortener.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.url_shortener.id
}

resource "aws_api_gateway_method" "short_url_create" {
  rest_api_id = aws_api_gateway_rest_api.url_shortener.id
  resource_id = aws_api_gateway_resource.short_url.id
  http_method = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "short_url_create" {
  depends_on = [
    aws_lambda_permission.url_shortener_lambda_short_url_create
  ]
  rest_api_id = aws_api_gateway_rest_api.url_shortener.id
  resource_id = aws_api_gateway_method.short_url_create.resource_id
  http_method = aws_api_gateway_method.short_url_create.http_method

  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.lambda_short_url_create.invoke_arn
}

// ================
// get original url
// ================
resource "aws_api_gateway_resource" "original_url" {
  path_part = "{hash}"
  parent_id = aws_api_gateway_rest_api.url_shortener.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.url_shortener.id
}

resource "aws_api_gateway_method" "original_url_get" {
  rest_api_id = aws_api_gateway_rest_api.url_shortener.id
  resource_id = aws_api_gateway_resource.original_url.id
  http_method = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.hash" = true
  }
}

resource "aws_api_gateway_integration" "original_url_get" {
  depends_on = [
    aws_lambda_permission.url_shortener_lambda_original_url_get
  ]
  rest_api_id = aws_api_gateway_rest_api.url_shortener.id
  resource_id = aws_api_gateway_method.original_url_get.resource_id
  http_method = aws_api_gateway_method.original_url_get.http_method

  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.lambda_original_url_get.invoke_arn

  request_parameters = {
    "integration.request.path.hash" = "method.request.path.hash"
  }
}

resource "aws_api_gateway_stage" "url_shortener_dev" {
  stage_name = "dev"
  rest_api_id = aws_api_gateway_rest_api.url_shortener.id
  deployment_id = aws_api_gateway_deployment.short_url.id

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.url_shortener_gw.arn

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

resource "aws_api_gateway_deployment" "short_url" {
  depends_on = [
    aws_api_gateway_integration.short_url_create,
    aws_api_gateway_method.short_url_create,
    aws_api_gateway_integration.original_url_get,
    aws_api_gateway_method.original_url_get
  ]

  rest_api_id = aws_api_gateway_rest_api.url_shortener.id
}

resource "aws_cloudwatch_log_group" "url_shortener_gw" {
  name = "/aws/api-gw/${aws_api_gateway_rest_api.url_shortener.name}"

  retention_in_days = 1
}
