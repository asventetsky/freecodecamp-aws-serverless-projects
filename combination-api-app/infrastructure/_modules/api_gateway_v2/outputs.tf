output "api_combiner_url" {
  description = "URL for Combination API app."

  value = aws_apigatewayv2_stage.this.invoke_url
}
