resource "null_resource" "install_dependencies" {
  provisioner "local-exec" {
    command = "sudo pip3 install -r ${var.lambda_root}/requirements.txt -t ${var.lambda_root}/"
  }
  
  triggers = {
    dependencies_versions = filemd5("${var.lambda_root}/requirements.txt")
    source_versions = filemd5("${var.lambda_root}/api_composer.py")
  }
}

resource "random_uuid" "api_composer_src_hash" {
  keepers = {
    for filename in setunion(
      fileset(var.lambda_root, "api_composer.py"),
      fileset(var.lambda_root, "requirements.txt")
    ):
        filename => filemd5("${var.lambda_root}/${filename}")
  }
}

data "archive_file" "api_composer_archive" {
  depends_on = [null_resource.install_dependencies]
  excludes   = [
    "__pycache__",
    "venv",
  ]

  source_dir  = var.lambda_root
  output_path = "api_composer-${random_uuid.api_composer_src_hash.result}.zip"
  type        = "zip"
}

resource "aws_lambda_function" "api_composer" {

  function_name = "api-composer"
  role          = aws_iam_role.api_composer_role.arn
  filename      = data.archive_file.api_composer_archive.output_path

  source_code_hash = data.archive_file.api_composer_archive.output_base64sha256

  handler = "api_composer.lambda_handler"

  runtime = "python3.9"

  tags = {
    "Terraform" = "true"
  }
}

resource "aws_iam_role" "api_composer_role" {
  name = "lambda-api-composer-role"


  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    "Terraform" = "true"
  }
}
