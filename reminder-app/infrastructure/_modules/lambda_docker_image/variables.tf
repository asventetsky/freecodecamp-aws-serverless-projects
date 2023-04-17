variable "region" {}

variable "env" {}

variable "name" {}

variable "ecr_repository_uri" {}

variable "tag" {}

variable "lambda_role_arn" {}

variable "environment_variables" {
  type = map(string)
}

variable "resource_tags" {
  type = map(string)
}
