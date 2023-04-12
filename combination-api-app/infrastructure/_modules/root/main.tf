#==============================#
# lambda function and iam role #
#==============================#
data "aws_iam_policy_document" "api_composer" {
  statement {
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:*"]
    effect = "Allow"
  }
}

module "lambda_api_composer_iam_role" {
  source = "github.com/asventetsky/freecodecamp-aws-serverless-projects-common//terraform/module/aws/lambda_iam_role?ref=1c71f0bcea456cecbedfc8b67cc540144217bb8d"

  region = var.region
  env = var.env
  lambda_name = "api_composer"
  policy_json_string = data.aws_iam_policy_document.api_composer.json

  resource_tags = var.resource_tags
}

module "lambda_api_composer" {
  source = "github.com/asventetsky/freecodecamp-aws-serverless-projects-common//terraform/module/aws/lambda_zip_archive?ref=1c71f0bcea456cecbedfc8b67cc540144217bb8d"

  name = "lambda-api_composer-${var.region}-${var.env}"
  path_to_archive = "./../../../../../../source/target/${var.lambda_api_composer_artifact_name}"
  lambda_role_arn = module.lambda_api_composer_iam_role.arn
  handler = "lambda_api_composer/main.lambda_handler"
  resource_tags = var.resource_tags

  environment_variables = {
    JOKES_URL = var.jokes_url
    JOKES_TIMEOUT = var.jokes_timeout
  }
}

module "api_gateway" {
  source = "../../../../../_modules/api_gateway_v2"

  api_gateway_name = "combination-api-app-${var.region}-${var.env}"
  protocol_type = "HTTP"
  stage = var.env

  integrations = {
    "GET /jokes" = {
      lambda_invoke_arn = module.lambda_api_composer.lambda_invoke_arn
      lambda_function_name = module.lambda_api_composer.lambda_name
    }
  }
}
