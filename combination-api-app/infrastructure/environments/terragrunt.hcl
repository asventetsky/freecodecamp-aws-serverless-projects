generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "aws" {
  region = "eu-central-1"
}
EOF
}

locals {
  # Parse the file path we're in to read the env name: e.g., env
  # will be "dev" in the dev folder, "stage" in the stage folder,
  # etc.
//  parsed = regex(".*/(?P<env>.*?)/.*", get_terragrunt_dir())
  env    = "dev"
  app_name = "combination-api-app"
}

remote_state {
  backend = "s3"
  config = {
    bucket = "freecodecamp-aws-serverless-projects-tf-state-${local.env}"
    region = "us-east-2"
    key    = "${local.app_name}/terraform.tfstate"
    encrypt = true
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

terraform {
  source = "${get_parent_terragrunt_dir()}/../_modules/root///"
}

inputs = {
  lambda_name = "lambda-api-combiner"
  env = "${local.env}"
  resource_tags = {
    Application = "${local.app_name}",
    Environment = "${local.env}",
    CreatedBy = "Terraform"
  }
}
