resource "aws_apigatewayv2_api" "this" {
  name = var.api_gateway_name
  protocol_type = var.protocol_type
}

resource "aws_apigatewayv2_stage" "this" {
  api_id = aws_apigatewayv2_api.this.id

  name = var.stage
  auto_deploy = true
}

#=======================#
# Cognito configuration #
#=======================#
resource "aws_cognito_user_pool" "this" {
  count = var.cognito_auth["enable"] ? 1 : 0

  name = "${aws_apigatewayv2_api.this.name}-user-pool"

  alias_attributes           = ["email"]
  auto_verified_attributes   = ["email"]

  password_policy {
    minimum_length = 8
    temporary_password_validity_days = 7
  }

  schema {
    attribute_data_type = "String"
    developer_only_attribute = false
    mutable = true
    name = "email"
    required = true
  }

  dynamic "verification_message_template" {
    for_each = var.cognito_auth["confirm_email_option"] == "CONFIRM_WITH_LINK" ? [1] : []
    content {
      default_email_option = "CONFIRM_WITH_LINK"
      email_subject_by_link = "Email Address Verification Request for ${var.api_gateway_name}"
      email_message_by_link = "We have received a request to authorize this email address for use with ${var.api_gateway_name}. If you requested this verification, please go to the following URL to confirm that you are authorized to use this email address:\n{##Click Here##}"
    }
  }

  dynamic "verification_message_template" {
    for_each = var.cognito_auth["confirm_email_option"] == "CONFIRM_WITH_CODE" ? [1] : []
    content {
      default_email_option = "CONFIRM_WITH_CODE"
      email_subject_by_link = "Email Address Verification Request for ${var.api_gateway_name}"
      email_message_by_link = "We have received a request to authorize this email address for use with ${var.api_gateway_name}. Here is your verification code:\n{####}"
    }
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }

    recovery_mechanism {
      name     = "verified_phone_number"
      priority = 2
    }
  }

  # https://github.com/hashicorp/terraform-provider-aws/issues/21654
  lifecycle {
    ignore_changes = [
      password_policy,
      schema
    ]
  }
}

# Required if default_email_option = "CONFIRM_WITH_LINK"
resource "aws_cognito_user_pool_domain" "this" {
  count = var.cognito_auth["enable"] && var.cognito_auth["confirm_email_option"] == "CONFIRM_WITH_LINK" ? 1 : 0

  domain       = "${aws_apigatewayv2_api.this.name}-domain"
  user_pool_id = aws_cognito_user_pool.this[0].id
}

resource "aws_cognito_user_pool_client" "this" {
  count = var.cognito_auth["enable"] ? 1 : 0

  name = "${aws_apigatewayv2_api.this.name}-user-pool-client"

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
  user_pool_id = aws_cognito_user_pool.this[0].id
}

resource "aws_apigatewayv2_authorizer" "this" {
  count = var.cognito_auth["enable"] ? 1 : 0

  name             = "${aws_apigatewayv2_api.this.name}-cognito-authorizer"
  api_id           = aws_apigatewayv2_api.this.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.this[0].id]
    issuer   = "https://${aws_cognito_user_pool.this[0].endpoint}"
  }
}

#==============================================#
# Declare routes, integrations and permissions #
#==============================================#
resource "aws_apigatewayv2_route" "this" {
  for_each = var.integrations

  api_id = aws_apigatewayv2_api.this.id

  route_key = each.key
  target = "integrations/${aws_apigatewayv2_integration.this[each.key].id}"
  authorization_type = "JWT"
  authorizer_id = aws_apigatewayv2_authorizer.this[0].id
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
