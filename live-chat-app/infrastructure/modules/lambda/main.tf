resource null_resource build_lambda_ecr_image {
  triggers = {
    python_file = md5(file(var.python_file_path))
    docker_file = md5(file(var.docker_file_path))
  }

  provisioner "local-exec" {
    command = <<EOF
           $(aws ecr get-login --region ${var.region} --no-include-email)
           cd ${var.folder_path}
           docker build -t ${var.ecr_repository_url}:${var.function_name} .
           docker push ${var.ecr_repository_url}:${var.function_name}
       EOF
  }
}

data aws_ecr_image lambda_image {
  depends_on = [
    null_resource.build_lambda_ecr_image
  ]
  repository_name = var.ecr_repository_name
  image_tag       = var.function_name
}

resource "aws_lambda_function" "lambda_reminder_create" {
  function_name = var.function_name
  role = var.iam_role_arn

  package_type = "Image"
  image_uri = "${var.ecr_repository_url}@${data.aws_ecr_image.lambda_image.id}"
}

resource "aws_cloudwatch_log_group" "lambda_reminder_create" {
  name = "/aws/lambda/${aws_lambda_function.lambda_reminder_create.function_name}"

  retention_in_days = 1
}