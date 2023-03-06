resource "aws_lambda_function" "api_combiner" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "${path.module}/../../../source/target/${var.lambda_artifact_name}"
  function_name = "lambda-${var.app_name}-${var.region}-${var.env}"
  role          = var.lambda_role_arn
  source_code_hash = filebase64sha256("${path.module}/../../../source/target/${var.lambda_artifact_name}")
  handler = "composer.lambda_handler"
  runtime = "python3.9"

  environment {
    variables = {
      JOKES_URL = var.jokes_url
      JOKES_TIMEOUT = var.jokes_timeout
    }
  }

  tags = var.resource_tags
}

resource "aws_cloudwatch_log_group" "lambda_api_combiner" {
  name = "/aws/lambda/${aws_lambda_function.api_combiner.function_name}"

  retention_in_days = 1
}
