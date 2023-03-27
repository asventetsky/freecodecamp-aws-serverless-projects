data "aws_iam_policy_document" "create_short_url" {
  statement {
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:*"]
    effect = "Allow"
  }
  statement {
    actions   = ["dynamodb:PutItem"]
    # TODO replace with link to actual resource
    resources = ["*"]
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "get_original_url" {
  statement {
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:*"]
    effect = "Allow"
  }
  statement {
    actions   = ["dynamodb:GetItem"]
    # TODO replace with link to actual resource
    resources = ["*"]
    effect = "Allow"
  }
}

# Create lambda iam role for create-short-url
module "lambda_create_short_url_iam_role" {
  source = "github.com/asventetsky/freecodecamp-aws-serverless-projects-common//terraform/module/aws/lambda_iam_role?ref=terraform-common-lambda-iam-role-module"

  region = var.region
  env = var.env
  lambda_name = "create_short_url"
  policy_json_string = data.aws_iam_policy_document.create_short_url.json

  resource_tags = var.resource_tags
}

# Create lambda iam role for get-original-url
module "lambda_get_original_url_iam_role" {
  source = "github.com/asventetsky/freecodecamp-aws-serverless-projects-common//terraform/module/aws/lambda_iam_role?ref=terraform-common-lambda-iam-role-module"

  region = var.region
  env = var.env
  lambda_name = "get_original_url"
  policy_json_string = data.aws_iam_policy_document.get_original_url.json

  resource_tags = var.resource_tags
}

module "dynamo_db" {
  source = "../../../../../_modules/dynamo_db"

  region = var.region
  env = var.env
  app_name = var.app_name

  resource_tags = var.resource_tags
}
