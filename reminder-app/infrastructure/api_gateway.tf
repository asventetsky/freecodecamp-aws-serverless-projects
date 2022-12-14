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

// ================
// get reminders
// ================
resource "aws_api_gateway_resource" "reminders_get" {
  path_part = "reminders"
  parent_id = aws_api_gateway_rest_api.reminder.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.reminder.id
}

resource "aws_api_gateway_method" "reminders_get" {
  rest_api_id = aws_api_gateway_rest_api.reminder.id
  resource_id = aws_api_gateway_resource.reminders_get.id
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "reminders_get" {
  depends_on = [
    aws_lambda_permission.lambda_reminders_get
  ]
  rest_api_id = aws_api_gateway_rest_api.reminder.id
  resource_id = aws_api_gateway_method.reminders_get.resource_id
  http_method = aws_api_gateway_method.reminders_get.http_method

  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.lambda_reminders_get.invoke_arn
}

// =====
// CORS
// =====
resource "aws_api_gateway_resource" "cors" {
  rest_api_id = aws_api_gateway_rest_api.reminder.id
  parent_id   = aws_api_gateway_rest_api.reminder.root_resource_id
  path_part   = "{cors+}"
}

resource "aws_api_gateway_method" "cors" {
  rest_api_id   = aws_api_gateway_rest_api.reminder.id
  resource_id   = aws_api_gateway_resource.cors.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cors" {
  rest_api_id = aws_api_gateway_rest_api.reminder.id
  resource_id = aws_api_gateway_resource.cors.id
  http_method = aws_api_gateway_method.cors.http_method
  type = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
    {
      statusCode = 200
    }
    )
  }
}

resource "aws_api_gateway_method_response" "cors" {
  depends_on = [aws_api_gateway_method.cors]
  rest_api_id = aws_api_gateway_rest_api.reminder.id
  resource_id = aws_api_gateway_resource.cors.id
  http_method = aws_api_gateway_method.cors.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true,
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "cors" {
  depends_on = [aws_api_gateway_integration.cors, aws_api_gateway_method_response.cors]
  rest_api_id = aws_api_gateway_rest_api.reminder.id
  resource_id = aws_api_gateway_resource.cors.id
  http_method = aws_api_gateway_method.cors.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'",
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET, POST'"
  }
}

//==========================================================

resource "aws_api_gateway_deployment" "reminder" {
  depends_on = [
    aws_api_gateway_integration.reminder_create,
    aws_api_gateway_method.reminder_create,
    aws_api_gateway_integration.reminders_get,
    aws_api_gateway_method.reminders_get,
    aws_api_gateway_integration_response.cors,
    aws_api_gateway_method.cors
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
