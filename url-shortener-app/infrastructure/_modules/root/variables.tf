variable "region" {}

variable "env" {}

variable "app_name" {}

variable "lambda_create_short_url_artifact_name" {}

variable "lambda_get_original_url_artifact_name" {}

variable "resource_tags" {
  type = map(string)
}
