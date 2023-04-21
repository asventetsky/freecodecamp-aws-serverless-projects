variable "region" {}

variable "env" {}

variable "app_name" {}

variable "ecr_repository_uri" {}

variable "lambda_reminder_create_version" {}

variable "resource_tags" {
  type = map(string)
}
