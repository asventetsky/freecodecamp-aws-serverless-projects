module "dynamo_db" {
  source = "../../../../../_modules/dynamo_db"

  region = var.region
  env = var.env

  resource_tags = var.resource_tags
}

#================================================#
# CREATE REMINDER: lambda function and iam role  #
#================================================#
data "aws_iam_policy_document" "reminder_create" {
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

module "lambda_reminder_create_iam_role" {
  source = "github.com/asventetsky/freecodecamp-aws-serverless-projects-common//terraform/module/aws/lambda_iam_role?ref=1c71f0bcea456cecbedfc8b67cc540144217bb8d"

  region = var.region
  env = var.env
  lambda_name = "lambda_reminder_create"
  policy_json_string = data.aws_iam_policy_document.reminder_create.json

  resource_tags = var.resource_tags
}

module "lambda_reminder_create" {
  source = "../../../../../_modules/lambda_docker_image"

  name = "lambda_reminder_create"
  region = var.region
  env = var.env
  lambda_role_arn = module.lambda_reminder_create_iam_role.arn
  ecr_repository_uri = var.ecr_repository_uri
  # TODO: move to variable
  tag = "lambda_reminder_create_5"

  environment_variables = {
    REGION = var.region
    TABLE_NAME = module.dynamo_db.table_name
  }

  resource_tags = var.resource_tags
}

#=============#
# API Gateway #
#=============#
module "api_gateway" {
  source = "github.com/asventetsky/freecodecamp-aws-serverless-projects-common//terraform/module/aws/api_gateway?ref=fd17f50c0e0ae0861e71a999eb307b6d428a8637"

  api_gateway_name = "reminder-app-${var.region}-${var.env}"
  cognito_auth = false
  stage = var.env

  integrations = {
    "POST /reminder" = {
      method = "POST"
      path_part = "reminder"
      lambda_invoke_arn = module.lambda_reminder_create.lambda_invoke_arn
      lambda_function_name = module.lambda_reminder_create.lambda_name
    }
  }
}
