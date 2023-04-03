resource "aws_dynamodb_table" "short_urls" {
  name = "short-urls-${var.app_name}-${var.region}-${var.env}"
  billing_mode = "PROVISIONED"
  read_capacity= "30"
  write_capacity= "30"

  attribute {
    name = "url_hash"
    type = "S"
  }

  hash_key = "url_hash"

  tags = var.resource_tags
}
