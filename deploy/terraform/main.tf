# the lambda code is zipped here, so it ships with the infrastructure
data "archive_file" "hello" {
  type        = "zip"
  source_file = "${path.module}/../../src/lambda/hello.py"
  output_path = "${path.module}/hello.zip"
}

resource "aws_iam_role" "hello" {
  name = "${local.resourceName}-lambda-role"
  assume_role_policy = <<EOF2
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "Service": "lambda.amazonaws.com" },
    "Action": "sts:AssumeRole"
  }]
}
EOF2
}

# the lambda may only write its own logs
resource "aws_iam_policy" "hello" {
  name = "${local.resourceName}-lambda-logs"
  policy = <<EOF2
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allowed",
    "Action": ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
    "Resource": "arn:aws:logs:*:*:*"
  }]
}
EOF2
}

resource "aws_iam_role_policy_attachment" "hello" {
  role       = aws_iam_role.hello.name
  policy_arn = aws_iam_policy.hello.arn
}

resource "aws_lambda_function" "hello" {
  function_name    = "${local.resourceName}-hello"
  role             = aws_iam_role.hello.arn
  runtime          = "python3.12"
  handler          = "hello.handler"
  filename         = data.archive_file.hello.output_path
  source_code_hash = data.archive_file.hello.output_base64sha256
}

# http api in front of the lambda
resource "aws_apigatewayv2_api" "hello" {
  name          = "${local.resourceName}-api-gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "hello" {
  api_id                 = aws_apigatewayv2_api.hello.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.hello.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "hello" {
  api_id    = aws_apigatewayv2_api.hello.id
  route_key = "GET /hello"
  target    = "integrations/${aws_apigatewayv2_integration.hello.id}"
}

resource "aws_apigatewayv2_stage" "hello" {
  api_id      = aws_apigatewayv2_api.hello.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "hello" {
  statement_id  = "AllowApiGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.hello.execution_arn}/*/*"
}
