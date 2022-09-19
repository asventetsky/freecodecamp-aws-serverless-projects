terraform {
  backend "s3" {
    bucket = "freecodecamp-aws-serverless-projects-tf-state"
    key    = "combination-api-project/terraform.tfstate"
    region = "eu-central-1"

    dynamodb_table = "freecodecamp-aws-serverless-projects-tf-lock"
  }
}