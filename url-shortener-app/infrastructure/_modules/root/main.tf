module "dynamo_db" {
  source = "../../../../../_modules/dynamo_db"

  region = var.region
  env = var.env
  app_name = var.app_name

  resource_tags = var.resource_tags
}

#===============================================
# CREATE SHORT URL: lambda function and iam role
#===============================================
data "aws_iam_policy_document" "create_short_url" {
  statement {
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:*"]
    effect = "Allow"
  }
  statement {
    actions   = ["dynamodb:PutItem"]
    resources = [module.dynamo_db.table_arn]
    effect = "Allow"
  }
}

module "lambda_create_short_url_iam_role" {
  source = "github.com/asventetsky/freecodecamp-aws-serverless-projects-common//terraform/module/aws/lambda_iam_role?ref=1c71f0bcea456cecbedfc8b67cc540144217bb8d"

  region = var.region
  env = var.env
  lambda_name = "create_short_url"
  policy_json_string = data.aws_iam_policy_document.create_short_url.json

  resource_tags = var.resource_tags
}

module "lambda_create_short_url" {
  source = "github.com/asventetsky/freecodecamp-aws-serverless-projects-common//terraform/module/aws/lambda_zip_archive?ref=1c71f0bcea456cecbedfc8b67cc540144217bb8d"

  name = "lambda-create_short_url-${var.region}-${var.env}"
  path_to_archive = "./../../../../../../source/target/${var.lambda_create_short_url_artifact_name}"
  lambda_role_arn = module.lambda_create_short_url_iam_role.arn
  handler = "lambda_create_short_url/main.lambda_handler"
  environment_variables = {}
  resource_tags = var.resource_tags
}

#===============================================
# GET ORIGINAL URL: lambda function and iam role
#===============================================
data "aws_iam_policy_document" "get_original_url" {
  statement {
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:*"]
    effect = "Allow"
  }
  statement {
    actions   = ["dynamodb:GetItem"]
    resources = [module.dynamo_db.table_arn]
    effect = "Allow"
  }
}

module "lambda_get_original_url_iam_role" {
  source = "github.com/asventetsky/freecodecamp-aws-serverless-projects-common//terraform/module/aws/lambda_iam_role?ref=1c71f0bcea456cecbedfc8b67cc540144217bb8d"

  region = var.region
  env = var.env
  lambda_name = "get_original_url"
  policy_json_string = data.aws_iam_policy_document.get_original_url.json

  resource_tags = var.resource_tags
}

module "lambda_get_original_url" {
  source = "github.com/asventetsky/freecodecamp-aws-serverless-projects-common//terraform/module/aws/lambda_zip_archive?ref=1c71f0bcea456cecbedfc8b67cc540144217bb8d"

  name = "lambda-get_original_url-${var.region}-${var.env}"
  path_to_archive = "./../../../../../../source/target/${var.lambda_get_original_url_artifact_name}"
  lambda_role_arn = module.lambda_get_original_url_iam_role.arn
  handler = "lambda_get_original_url/main.lambda_handler"
  environment_variables = {}
  resource_tags = var.resource_tags
}

#===============================================
# API Gateway
#===============================================
module "api_gateway" {
  source = "github.com/asventetsky/freecodecamp-aws-serverless-projects-common//terraform/module/aws/api_gateway?ref=terraform-api-gateway-module"

  api_gateway_name = "url-shortener-app-${var.region}-${var.env}"
}

module "api_gateway_resource_create_short_url" {
  source = "github.com/asventetsky/freecodecamp-aws-serverless-projects-common//terraform/module/aws/api_gateway_resource?ref=terraform-api-gateway-module"

  api_gateway_id = module.api_gateway.id
  api_gateway_root_resource_id = module.api_gateway.root_resource_id
  api_gateway_execution_arn = module.api_gateway.execution_arn
  path_part = "short-url"
  method = "POST"
  lambda_invoke_arn = module.lambda_create_short_url.lambda_invoke_arn
  lambda_function_name = module.lambda_create_short_url.lambda_name
}

module "api_gateway_resource_get_original_url" {
  source = "github.com/asventetsky/freecodecamp-aws-serverless-projects-common//terraform/module/aws/api_gateway_resource?ref=terraform-api-gateway-module"

  api_gateway_id = module.api_gateway.id
  api_gateway_root_resource_id = module.api_gateway.root_resource_id
  api_gateway_execution_arn = module.api_gateway.execution_arn
  path_part = "{url_hash}"
  method = "GET"
  lambda_invoke_arn = module.lambda_get_original_url.lambda_invoke_arn
  lambda_function_name = module.lambda_get_original_url.lambda_name
}
