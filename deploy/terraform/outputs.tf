output "api_url" {
  value = "${aws_apigatewayv2_api.hello.api_endpoint}/hello"
}
