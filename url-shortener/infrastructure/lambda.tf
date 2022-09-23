locals {
  tags = {
    "Terraform" = "true"
  }
}

// ========================
// lambda-short-url-create
// ========================
data "archive_file" "lambda_short_url_create_archive" {
  source_file  = "../source/lambda_short_url_create.py"
  output_path = "lambda_short_url_create.zip"
  type        = "zip"
}

resource "aws_lambda_function" "lambda_short_url_create" {

  function_name = "lambda-short-url-create"
  role          = aws_iam_role.lambda_short_url_role.arn
  filename      = data.archive_file.lambda_short_url_create_archive.output_path
  source_code_hash = data.archive_file.lambda_short_url_create_archive.output_base64sha256
  handler = "lambda_short_url_create.lambda_handler"
  runtime = "python3.9"

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "lambda_short_url_create" {
  name = "/aws/lambda/${aws_lambda_function.lambda_short_url_create.function_name}"

  retention_in_days = 1
}
