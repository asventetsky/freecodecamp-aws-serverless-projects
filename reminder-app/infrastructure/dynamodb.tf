resource "aws_dynamodb_table" "reminders" {
  name = "reminders"

  billing_mode = "PROVISIONED"
  read_capacity= "30"
  write_capacity= "30"

  hash_key = "id"
  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"

  attribute {
    name = "id"
    type = "S"
  }

  tags = local.tags
}
