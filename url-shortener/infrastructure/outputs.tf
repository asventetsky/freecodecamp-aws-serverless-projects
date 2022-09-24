output "api_gateway_url" {
  description = "URL for Short URL project"
  value = aws_api_gateway_stage.short_url_dev.invoke_url
}