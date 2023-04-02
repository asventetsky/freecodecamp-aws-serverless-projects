output "table_arn" {
  description = "DynamoDB table ARN"

  value = aws_dynamodb_table.short_urls.arn
}
