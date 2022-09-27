output "api_gateway_url" {
  description = "URL for URL Shortener project"
  value = aws_api_gateway_stage.url_shortener_dev.invoke_url
}