resource "aws_api_gateway_rest_api" "reminder" {
  name = "reminder"
}

// ================
// create reminder
// ================
resource "aws_api_gateway_resource" "reminder_create" {
  path_part = "reminder"
  parent_id = aws_api_gateway_rest_api.reminder.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.reminder.id
}

resource "aws_api_gateway_method" "reminder_create" {
  rest_api_id = aws_api_gateway_rest_api.reminder.id
  resource_id = aws_api_gateway_resource.reminder_create.id
  http_method = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "reminder_create" {
  depends_on = [
    aws_lambda_permission.lambda_reminder_create
  ]
  rest_api_id = aws_api_gateway_rest_api.reminder.id
  resource_id = aws_api_gateway_method.reminder_create.resource_id
  http_method = aws_api_gateway_method.reminder_create.http_method

  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.lambda_reminder_create.invoke_arn
}

resource "aws_api_gateway_deployment" "reminder" {
  depends_on = [
    aws_api_gateway_integration.reminder_create,
    aws_api_gateway_method.reminder_create
  ]

  rest_api_id = aws_api_gateway_rest_api.reminder.id
}

resource "aws_api_gateway_stage" "reminder_dev" {
  stage_name = "dev"
  rest_api_id = aws_api_gateway_rest_api.reminder.id
  deployment_id = aws_api_gateway_deployment.reminder.id

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.reminder_gw.arn

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

resource "aws_cloudwatch_log_group" "reminder_gw" {
  name = "/aws/api-gw/${aws_api_gateway_rest_api.reminder.name}"

  retention_in_days = 1
}
