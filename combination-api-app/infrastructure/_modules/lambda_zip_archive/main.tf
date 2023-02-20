resource "aws_lambda_function" "api_combiner" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "${var.lambda_name}.zip"
  function_name = var.lambda_name
  role          = var.lambda_role_arn
  source_code_hash = filebase64sha256("${var.lambda_name}.zip")
  handler = "composer.lambda_handler"
  runtime = "python3.9"

  tags = var.resource_tags
}

resource "aws_cloudwatch_log_group" "lambda_api_combiner" {
  name = "/aws/lambda/${aws_lambda_function.api_combiner.function_name}"

  retention_in_days = 1
}
