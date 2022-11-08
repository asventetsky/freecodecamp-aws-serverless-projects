resource "aws_iam_role" "lambda" {
  name = var.name

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
}

data "template_file" "lambda" {
  template = file(var.policy_json_filename)
  vars = var.policy_json_variables
}

resource "aws_iam_policy" "lambda" {
  name = "${var.name}-policy"
  policy = data.template_file.lambda.rendered
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}
