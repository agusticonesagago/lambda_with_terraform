data "aws_caller_identity" "current" {
}

variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}

provider "aws" {
  region     = "us-west-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

terraform {
  backend "s3" {
    bucket = "lambda-save-tfstate"
    key    = "status"
    region = "us-west-2"
  }
}

resource "aws_lambda_function" "example_lambda" {
  function_name = "example_lambda_function"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "lambda.handler"
  runtime       = "python3.8"
  filename      = "lambda.zip"
}

resource "aws_iam_role" "lambda_execution_role" {
  name               = "lambda_execution_role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_execution_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_execution_role.name
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "lambda_code"
  output_path = "lambda.zip"
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "example-lambda-bucket-random"
}

resource "aws_s3_object" "lambda_object" {
  key     = "lambda.zip"
  bucket  = aws_s3_bucket.lambda_bucket.id
  source  = data.archive_file.lambda_zip.output_path
}

resource "aws_iam_role" "api_gateway_role" {
  name = "api_gateway_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_invoke_policy" {
  name = "lambda_invoke_policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "lambda:InvokeFunction",
      "Resource": "${aws_lambda_function.example_lambda.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "api_gateway_policy_attachment" {
  role       = aws_iam_role.api_gateway_role.name
  policy_arn = aws_iam_policy.lambda_invoke_policy.arn
}

resource "aws_api_gateway_rest_api" "example_api" {
  name        = "example_api"
  description = "Example API"
}

resource "aws_api_gateway_resource" "example_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.example_api.id
  parent_id   = aws_api_gateway_rest_api.example_api.root_resource_id
  path_part   = "example"
}

data "aws_lambda_function" "existing_lambda" {
  function_name = "Authorizer"
}
output "lambda_invoke_arn" {
  value = data.aws_lambda_function.existing_lambda.invoke_arn
}

resource "aws_api_gateway_authorizer" "example_authorizer" {
  name                   = "example_authorizer"
  rest_api_id            = aws_api_gateway_rest_api.example_api.id
  type                   = "REQUEST"
  authorizer_uri         = data.aws_lambda_function.existing_lambda.invoke_arn
  authorizer_result_ttl_in_seconds = 300
}

resource "aws_api_gateway_method" "example_api_method" {
  rest_api_id   = aws_api_gateway_rest_api.example_api.id
  resource_id   = aws_api_gateway_resource.example_api_resource.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.example_authorizer.id
}

resource "aws_api_gateway_integration" "example_api_integration" {
  rest_api_id             = aws_api_gateway_rest_api.example_api.id
  resource_id             = aws_api_gateway_resource.example_api_resource.id
  http_method             = aws_api_gateway_method.example_api_method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.example_lambda.invoke_arn
}

resource "aws_api_gateway_method_response" "example_method_response" {
  rest_api_id       = aws_api_gateway_rest_api.example_api.id
  resource_id       = aws_api_gateway_resource.example_api_resource.id
  http_method       = aws_api_gateway_method.example_api_method.http_method
  status_code       = "200"
  response_models   = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "example_integration_response" {
  rest_api_id       = aws_api_gateway_rest_api.example_api.id
  resource_id       = aws_api_gateway_resource.example_api_resource.id
  http_method       = aws_api_gateway_method.example_api_method.http_method
  status_code       = aws_api_gateway_method_response.example_method_response.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_api_gateway_deployment" "example_deployment" {
  rest_api_id = aws_api_gateway_rest_api.example_api.id
  stage_name  = "prod"
}

resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.example_api.execution_arn}/*/${aws_api_gateway_method.example_api_method.http_method}/${aws_api_gateway_resource.example_api_resource.path_part}"

  depends_on = [aws_api_gateway_deployment.example_deployment]
}

output "api_gateway_url" {
  value = aws_api_gateway_deployment.example_deployment.invoke_url
}
