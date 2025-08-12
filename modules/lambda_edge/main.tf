resource "aws_lambda_function" "this" {
  filename         = var.lambda_zip_file_path
  function_name    = var.function_name
  handler          = var.handler
  runtime          = var.runtime
  role             = var.role_arn
  publish          = true
  source_code_hash = filebase64sha256(var.lambda_zip_file_path)

  environment {
    variables = {
      ENVIRONMENT = var.environment
    }
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_lambda_version" "current" {
  function_name = aws_lambda_function.this.function_name
  depends_on    = [aws_lambda_function.this]
}

