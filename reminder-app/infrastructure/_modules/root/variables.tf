variable "region" {}

variable "env" {}

variable "app_name" {}

variable "ecr_repository_uri" {}

variable "resource_tags" {
  type = map(string)
}
