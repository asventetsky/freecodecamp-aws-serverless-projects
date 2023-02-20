module "iam" {
  source = "../iam"

  lambda_name = var.lambda_name
  resource_tags = var.resource_tags
}

module "lambda" {
  source = "../lambda_zip_archive"

  resource_tags = var.resource_tags
  lambda_name = var.lambda_name
  lambda_role_arn = module.iam.role_arn
}
