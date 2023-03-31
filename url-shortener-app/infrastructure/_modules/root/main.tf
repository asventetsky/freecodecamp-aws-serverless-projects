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
    resources = [module.dynamo_db.dynamo_db_table_arn]
    effect = "Allow"
  }
}

module "lambda_create_short_url_iam_role" {
  source = "github.com/asventetsky/freecodecamp-aws-serverless-projects-common//terraform/module/aws/lambda_iam_role?ref=1eaced0c1f720983105f83ea01875b4b994e5e91"

  region = var.region
  env = var.env
  lambda_name = "create_short_url"
  policy_json_string = data.aws_iam_policy_document.create_short_url.json

  resource_tags = var.resource_tags
}

module "lambda_create_short_url" {
  source = "github.com/asventetsky/freecodecamp-aws-serverless-projects-common//terraform/module/aws/lambda_zip_archive?ref=1eaced0c1f720983105f83ea01875b4b994e5e91"

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
    resources = [module.dynamo_db.dynamo_db_table_arn]
    effect = "Allow"
  }
}

module "lambda_get_original_url_iam_role" {
  source = "github.com/asventetsky/freecodecamp-aws-serverless-projects-common//terraform/module/aws/lambda_iam_role?ref=terraform-lambda-zip-archive-module"

  region = var.region
  env = var.env
  lambda_name = "get_original_url"
  policy_json_string = data.aws_iam_policy_document.get_original_url.json

  resource_tags = var.resource_tags
}

module "lambda_get_original_url" {
  source = "github.com/asventetsky/freecodecamp-aws-serverless-projects-common//terraform/module/aws/lambda_zip_archive?ref=terraform-lambda-zip-archive-module"

  name = "lambda-get_original_url-${var.region}-${var.env}"
  path_to_archive = "./../../../../../../source/target/${var.lambda_get_original_url_artifact_name}"
  lambda_role_arn = module.lambda_get_original_url_iam_role.arn
  handler = "lambda_get_original_url/main.lambda_handler"
  environment_variables = {}
  resource_tags = var.resource_tags
}