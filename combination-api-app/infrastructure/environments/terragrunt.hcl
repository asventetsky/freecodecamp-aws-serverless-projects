generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::0123456789:role/terragrunt"
  }
}
EOF
}

locals {
  # Parse the file path we're in to read the env name: e.g., env
  # will be "dev" in the dev folder, "stage" in the stage folder,
  # etc.
  parsed = regex(".*/environments/(?P<env>.*?)/.*", get_terragrunt_dir())
  env    = local.parsed.env
  app_name = "combination-api-app"
}

remote_state {
  backend = "s3"
  config = {
    bucket = "freecodecamp-aws-serverless-projects-tf-state-${local.env}"
    region = "us-east-2"
    key    = "${locals.app_name}/terraform.tfstate"
    encrypt = true
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

terraform {
  source = "../_modules/root"
}

inputs = {
  lambda_name = "lambda-api-combiner"
  resource_tags = {
    Application = "${locals.app_name}"
    Environment = "${locals.env}"
    CreatedBy = "Terraform"
  }
}
