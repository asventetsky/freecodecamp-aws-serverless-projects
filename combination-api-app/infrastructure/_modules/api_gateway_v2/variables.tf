variable "region" {}

variable "env" {}

variable "app_name" {}

variable "lambda_name" {}

variable "path" {
  default = "/jokes"
}

variable "lambda_invoke_arn" {}