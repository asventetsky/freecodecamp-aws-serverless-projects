variable "api_gateway_name" {}

variable "protocol_type" {
  description = "Possible values are `HTTP` and `WEBSOCKET`"
}

variable "stage" {}

variable "integrations" {
  description = "List of API Gateway routes with integrations"
  type        = map(object({
    lambda_invoke_arn = string
    lambda_function_name = string
  }))
  default = {}
}
