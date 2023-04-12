resource "aws_apigatewayv2_api" "this" {
  name = var.api_gateway_name
  protocol_type = var.protocol_type
}

resource "aws_apigatewayv2_stage" "this" {
  api_id = aws_apigatewayv2_api.this.id

  name = var.stage
  auto_deploy = true
}

#==============================================#
# Declare routes, integrations and permissions #
#==============================================#
resource "aws_apigatewayv2_route" "this" {
  for_each = var.integrations

  api_id = aws_apigatewayv2_api.this.id

  route_key = each.key
  target = "integrations/${aws_apigatewayv2_integration.this[each.key].id}"
}

resource "aws_apigatewayv2_integration" "this" {
  for_each = var.integrations

  api_id = aws_apigatewayv2_api.this.id
  integration_type = "AWS_PROXY"

  integration_method = "POST"
  integration_uri = each.value.lambda_invoke_arn
}

resource "aws_lambda_permission" "this" {
  for_each = var.integrations

  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}
