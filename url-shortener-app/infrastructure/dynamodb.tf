resource "aws_dynamodb_table" "short_urls" {
  name = "short-urls"
  billing_mode = "PROVISIONED"
  read_capacity= "30"
  write_capacity= "30"

  attribute {
    name = "hash"
    type = "S"
  }

  hash_key = "hash"

  tags = local.tags
}
