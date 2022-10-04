output "api_gateway_url" {
  description = "URL for Reminder App"
  value = aws_api_gateway_stage.reminder_dev.invoke_url
}