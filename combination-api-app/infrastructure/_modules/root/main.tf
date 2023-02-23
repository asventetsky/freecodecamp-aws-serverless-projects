module "iam" {
  source = "../../../../../_modules/iam"

  lambda_name = var.lambda_name
  resource_tags = var.resource_tags
}

module "lambda" {
  source = "../../../../../_modules/lambda_zip_archive"

  resource_tags = var.resource_tags
  lambda_name = var.lambda_name
  lambda_role_arn = module.iam.role_arn
}

module "api_gateway" {
  source = "../../../../../_modules/api_gateway_v2"

  env = var.env
  lambda_name = var.lambda_name
  lambda_invoke_arn = module.lambda.lambda_invoke_arn
}
