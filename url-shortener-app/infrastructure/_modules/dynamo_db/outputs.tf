output "dynamo_db_table_name" {
  description = "DynamoDB table name"

  value = aws_dynamodb_table.short_urls.name
}
