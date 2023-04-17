resource "aws_lambda_function" "this" {
  function_name = "${var.name}-${var.region}-${var.env}"
  role          = var.lambda_role_arn

  package_type = "Image"
  image_uri = "${var.ecr_repository_uri}:${var.tag}"

  environment {
    variables = var.environment_variables
  }

  tags = var.resource_tags
}

resource "aws_cloudwatch_log_group" "lambda" {
  name = "/aws/lambda/${aws_lambda_function.this.function_name}"

  retention_in_days = 1
}
