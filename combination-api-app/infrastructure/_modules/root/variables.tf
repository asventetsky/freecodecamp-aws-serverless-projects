variable "region" {}

variable "env" {}

variable "app_name" {}

variable "lambda_artifact_name" {}

variable "resource_tags" {
  type = map(string)
}
