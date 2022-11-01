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

module "websocket_api_gateway" {
  source = "../modules/api_gateway"
}

module "dynamodb_table" {
  source = "../modules/dynamodb"
}