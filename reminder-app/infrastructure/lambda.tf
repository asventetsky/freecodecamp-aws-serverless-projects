// ============================
// lambda-reminder-event-create
// ============================
resource "aws_ecr_repository" "ecr_repo" {
  name = "reminder-app"
}

resource null_resource build_lambda_reminder_event_create_ecr_image {
  triggers = {
    python_file = md5(file("../source/backend/lambda-reminder-event-create/lambda_reminder_event_create.py"))
    docker_file = md5(file("../source/backend/lambda-reminder-event-create/Dockerfile"))
  }

  provisioner "local-exec" {
    command = <<EOF
           $(aws ecr get-login --region ${var.region} --no-include-email)
           cd ../source/backend/lambda-reminder-event-create
           docker build -t ${aws_ecr_repository.ecr_repo.repository_url}:${local.lambda_reminder_event_create} .
           docker push ${aws_ecr_repository.ecr_repo.repository_url}:${local.lambda_reminder_event_create}
       EOF
  }
}

data aws_ecr_image lambda_image {
  depends_on = [
    null_resource.build_lambda_reminder_event_create_ecr_image
  ]
  repository_name = aws_ecr_repository.ecr_repo.name
  image_tag       = local.lambda_reminder_event_create
}

resource "aws_lambda_function" "lambda_reminder_event_create" {
  function_name = "lambda-reminder-event-create"
  role = aws_iam_role.lambda_reminder_event_create_role.arn

  package_type = "Image"
  image_uri = "${aws_ecr_repository.ecr_repo.repository_url}@${data.aws_ecr_image.lambda_image.id}"

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "lambda_reminder_event_create" {
  name = "/aws/lambda/${aws_lambda_function.lambda_reminder_event_create.function_name}"

  retention_in_days = 1
}

// ============================
// lambda-reminder-send
// ============================
resource null_resource build_lambda_reminder_send_ecr_image {
  triggers = {
    python_file = md5(file("../source/backend/lambda-reminder-send/lambda_reminder_send.py"))
    docker_file = md5(file("../source/backend/lambda-reminder-send/Dockerfile"))
  }

  provisioner "local-exec" {
    command = <<EOF
           $(aws ecr get-login --region ${var.region} --no-include-email)
           cd ../source/backend/lambda-reminder-send
           docker build -t ${aws_ecr_repository.ecr_repo.repository_url}:${local.lambda_reminder_send} .
           docker push ${aws_ecr_repository.ecr_repo.repository_url}:${local.lambda_reminder_send}
       EOF
  }
}

data aws_ecr_image lambda_reminder_send_image {
  depends_on = [
    null_resource.build_lambda_reminder_send_ecr_image
  ]
  repository_name = aws_ecr_repository.ecr_repo.name
  image_tag       = local.lambda_reminder_send
}

resource "aws_lambda_function" "lambda_reminder_send" {
  function_name = "lambda-reminder-send"
  role = aws_iam_role.lambda_reminder_event_create_role.arn

  package_type = "Image"
  image_uri = "${aws_ecr_repository.ecr_repo.repository_url}@${data.aws_ecr_image.lambda_reminder_send_image.id}"

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "lambda_reminder_send" {
  name = "/aws/lambda/${aws_lambda_function.lambda_reminder_send.function_name}"

  retention_in_days = 1
}
