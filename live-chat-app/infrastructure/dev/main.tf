provider "aws" {
  region = var.region
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "=4.30.0"
    }
  }
}

terraform {
  backend "s3" {
    bucket = "freecodecamp-aws-serverless-projects-tf-state"
    key = "live-chat-app/terraform.tfstate"
    region = "eu-central-1"

    dynamodb_table = "freecodecamp-aws-serverless-projects-tf-lock"
  }
}

module "dynamodb_table" {
  source = "../modules/dynamodb"
}

module "ecr" {
  source = "../modules/ecr"

  repository_name = "live-chat"
}

data "template_file" "lambda_connect" {
  template = file("${var.lambda_live_chat_connect}_policy.json")

  vars = {
    dynamodb_table_arn = module.dynamodb_table.arn
  }
}

module "lambda_connect_iam_role" {
  source = "../modules/iam_lambda"

  name = var.lambda_live_chat_connect
  policy_json = data.template_file.lambda_connect.rendered
}

module "lambda_connect" {
  source = "../modules/lambda"

  region = var.region
  function_name = var.lambda_live_chat_connect
  folder_path = "../../source/backend/${var.lambda_live_chat_connect}"
  python_file_path = "../../source/backend/${var.lambda_live_chat_connect}/lambda.py"
  docker_file_path = "../../source/backend/${var.lambda_live_chat_connect}/Dockerfile"
  ecr_repository_name = module.ecr.repository_name
  ecr_repository_url = module.ecr.repository_url
  iam_role_arn = module.lambda_connect_iam_role.arn
}

data "template_file" "lambda_create_room" {
  template = file("${var.lambda_live_chat_create_room}_policy.json")

  vars = {
    dynamodb_table_arn = module.dynamodb_table.arn
  }
}

module "lambda_create_room_iam_role" {
  source = "../modules/iam_lambda"

  name = var.lambda_live_chat_create_room
  policy_json = data.template_file.lambda_create_room.rendered
}

module "lambda_create_room" {
  source = "../modules/lambda"

  region = var.region
  function_name = var.lambda_live_chat_create_room
  folder_path = "../../source/backend/${var.lambda_live_chat_create_room}"
  python_file_path = "../../source/backend/${var.lambda_live_chat_create_room}/lambda.py"
  docker_file_path = "../../source/backend/${var.lambda_live_chat_create_room}/Dockerfile"
  ecr_repository_name = module.ecr.repository_name
  ecr_repository_url = module.ecr.repository_url
  iam_role_arn = module.lambda_connect_iam_role.arn

  environment_variables = {
    endpoint_url = module.websocket_api_gateway.url
  }
}

module "websocket_api_gateway" {
  source = "../modules/api_gateway"

  lambda_connect_invoke_arn = module.lambda_connect.invoke_arn
  lambda_connect_name = module.lambda_connect.name

  lambda_create_room_invoke_arn = module.lambda_create_room.invoke_arn
  lambda_create_room_name = module.lambda_create_room.name
}
