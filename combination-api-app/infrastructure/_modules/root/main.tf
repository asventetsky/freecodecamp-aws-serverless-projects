# TODO: update source path for each module
module "iam" {
  source = "../../../../../_modules/iam"

  region = var.region
  env = var.env
  app_name = var.app_name

  resource_tags = var.resource_tags
}

module "lambda" {
  source = "../../../../../_modules/lambda_zip_archive"

  region = var.region
  env = var.env
  app_name = var.app_name
  lambda_artifact_name = var.lambda_artifact_name
  lambda_role_arn = module.iam.role_arn
  jokes_url = var.jokes_url
  jokes_timeout = var.jokes_timeout

  resource_tags = var.resource_tags
}

module "api_gateway" {
  source = "../../../../../_modules/api_gateway_v2"

  region = var.region
  env = var.env
  app_name = var.app_name
  lambda_name = module.lambda.lambda_name
  lambda_invoke_arn = module.lambda.lambda_invoke_arn
}
