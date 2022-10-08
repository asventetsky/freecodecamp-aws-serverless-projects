locals {
  tags = {
    "Terraform" = "true"
  }

  account_id = "377194633523"

  lambda_reminder_create = "lambda_reminder_create"
  lambda_reminders_get = "lambda_reminders_get"
  lambda_reminder_event_create = "lambda_reminder_event_create"
  lambda_reminder_send = "lambda_reminder_send"
}

variable "region" {
  default = "eu-central-1"
}
