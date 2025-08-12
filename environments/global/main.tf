provider "aws" {
  region = "us-east-1" # Required for Lambda@Edge and global resources
}

# Lambda@Edge function deployment module
module "lambda_edge" {
  source               = "../../modules/lambda_edge"
  function_name        = "global-lambda-edge-function"
  handler              = "index.lambda_edge_routing"
  runtime              = "python3.9"
  role_arn             = var.lambda_edge_execution_arn
  lambda_zip_file_path = var.lambda_zip_file_path
  environment          = var.environment
}

