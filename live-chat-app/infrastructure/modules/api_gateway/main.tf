resource "aws_apigatewayv2_api" "live_chat" {
  name                       = "live-chat-api"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}

resource "aws_apigatewayv2_route" "live_chat_connect" {
  api_id    = aws_apigatewayv2_api.live_chat.id
  route_key = "$connect"
}

//resource "aws_apigatewayv2_deployment" "live_chat" {
//  depends_on = [
//
//  ]
//  api_id      = aws_apigatewayv2_api.live_chat.id
//
//  lifecycle {
//    create_before_destroy = true
//  }
//}

resource "aws_apigatewayv2_stage" "live_chat_dev" {
  api_id = aws_apigatewayv2_api.live_chat.id
  name   = "dev"
}
