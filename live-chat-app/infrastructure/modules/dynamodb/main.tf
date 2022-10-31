resource "aws_dynamodb_table" "live_chat" {
  name = "live-chat"

  billing_mode = "PROVISIONED"
  read_capacity= "30"
  write_capacity= "30"

  hash_key = "connectionId"

  attribute {
    name = "connectionId"
    type = "S"
  }
}
