output "api_combiner_url" {
  description = "URL for Combination API app."

  value = aws_apigatewayv2_stage.api_combiner.invoke_url
}
