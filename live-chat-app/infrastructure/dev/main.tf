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

data "aws_caller_identity" "current" {}

module "dynamodb_table" {
  source = "../modules/dynamodb"
}

module "ecr" {
  source = "../modules/ecr"

  repository_name = "live-chat"
}

module "lambda_connect_iam_role" {
  source = "../modules/iam_lambda"

  name = var.lambda_live_chat_connect
  policy_json_filename = "${var.lambda_live_chat_connect}_policy.json"
  policy_json_variables = {
    dynamodb_table_arn = module.dynamodb_table.arn
  }
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

  environment_variables = {
    createdBy = "terraform"
  }
}

module "lambda_create_room_iam_role" {
  source = "../modules/iam_lambda"

  name = var.lambda_live_chat_create_room
  policy_json_filename = "${var.lambda_live_chat_create_room}_policy.json"
  policy_json_variables = {
    dynamodb_table_arn = module.dynamodb_table.arn
    api_gateway_arn = join("", [
      "arn:aws:execute-api:",
      var.region,
      ":",
      data.aws_caller_identity.current.account_id,
      ":*/*/POST/@connections/*"])
  }
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
  iam_role_arn = module.lambda_create_room_iam_role.arn

  environment_variables = {
    endpoint_url = module.websocket_api_gateway.url
    createdBy = "terraform"
  }
}

module "lambda_join_room_iam_role" {
  source = "../modules/iam_lambda"

  name = var.lambda_live_chat_join_room
  policy_json_filename = "${var.lambda_live_chat_join_room}_policy.json"
  policy_json_variables = {
    dynamodb_table_arn = module.dynamodb_table.arn
  }
}

module "lambda_join_room" {
  source = "../modules/lambda"

  region = var.region
  function_name = var.lambda_live_chat_join_room
  folder_path = "../../source/backend/${var.lambda_live_chat_join_room}"
  python_file_path = "../../source/backend/${var.lambda_live_chat_join_room}/lambda.py"
  docker_file_path = "../../source/backend/${var.lambda_live_chat_join_room}/Dockerfile"
  ecr_repository_name = module.ecr.repository_name
  ecr_repository_url = module.ecr.repository_url
  iam_role_arn = module.lambda_join_room_iam_role.arn

  environment_variables = {
    createdBy = "terraform"
  }
}

module "lambda_send_message_iam_role" {
  source = "../modules/iam_lambda"

  name = var.lambda_live_chat_send_message
  policy_json_filename = "${var.lambda_live_chat_send_message}_policy.json"
  policy_json_variables = {
    dynamodb_table_arn = module.dynamodb_table.arn
  }
}

module "lambda_send_message" {
  source = "../modules/lambda"

  region = var.region
  function_name = var.lambda_live_chat_send_message
  folder_path = "../../source/backend/${var.lambda_live_chat_send_message}"
  python_file_path = "../../source/backend/${var.lambda_live_chat_send_message}/lambda.py"
  docker_file_path = "../../source/backend/${var.lambda_live_chat_send_message}/Dockerfile"
  ecr_repository_name = module.ecr.repository_name
  ecr_repository_url = module.ecr.repository_url
  iam_role_arn = module.lambda_send_message_iam_role.arn

  environment_variables = {
    createdBy = "terraform"
  }
}

module "websocket_api_gateway" {
  source = "../modules/api_gateway"

  lambda_connect_invoke_arn = module.lambda_connect.invoke_arn
  lambda_connect_name = module.lambda_connect.name

  lambda_create_room_invoke_arn = module.lambda_create_room.invoke_arn
  lambda_create_room_name = module.lambda_create_room.name

  lambda_join_room_invoke_arn = module.lambda_join_room.invoke_arn
  lambda_join_room_name = module.lambda_join_room.name

  lambda_send_message_invoke_arn = module.lambda_send_message.invoke_arn
  lambda_send_message_name = module.lambda_send_message.name
}
