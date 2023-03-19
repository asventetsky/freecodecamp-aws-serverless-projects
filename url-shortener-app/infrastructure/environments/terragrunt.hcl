generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "=4.57.0"
    }
  }
}

provider "aws" {
  region = "${local.region}"
}
EOF
}

locals {
  common_vars = yamldecode(file("${get_parent_terragrunt_dir()}/common_vars.yaml"))
  env_vars = yamldecode(file("${path_relative_to_include()}/env_vars.yaml"))
  parsed = regex(".*/infrastructure/environments/(?P<env>.*)", get_terragrunt_dir())

  env = local.parsed.env
  region = local.env_vars.region
  app_name = local.common_vars.app_name
  lambda_artifact_name = local.common_vars.lambda_artifact_name
  s3_bucket_prefix = local.common_vars.s3_bucket_prefix
}

remote_state {
  backend = "s3"
  config = {
    bucket = "${local.s3_bucket_prefix}-${local.region}"
    region = "${local.region}"
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
  region = "${local.region}"
  env = "${local.env}"
  app_name = "${local.app_name}"
  lambda_artifact_name = "${local.lambda_artifact_name}"
  resource_tags = {
    Application = "${local.app_name}",
    Environment = "${local.env}",
    CreatedBy = "Terraform"
  }
}
