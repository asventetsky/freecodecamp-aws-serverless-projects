variable "region" {}

variable "env" {}

variable "app_name" {}

variable "lambda_api_composer_artifact_name" {}

variable "jokes_url" {}

variable "jokes_timeout" {}

variable "resource_tags" {
  type = map(string)
}
