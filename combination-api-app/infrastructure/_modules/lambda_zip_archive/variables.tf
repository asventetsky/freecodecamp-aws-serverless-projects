variable "region" {}

variable "env" {}

variable "app_name" {}

variable "lambda_artifact_name" {}

variable "lambda_role_arn" {}

variable "jokes_url" {}

variable "jokes_timeout" {
  type = number
}

variable "resource_tags" {
  type = map(string)
}
