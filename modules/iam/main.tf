# IAM Role for EC2 WordPress Instance
resource "aws_iam_role" "ec2_wordpress" {
  name               = "${var.environment}-ec2-wordpress-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
}

data "aws_iam_policy_document" "ec2_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "secrets_access" {
  name = "${var.environment}-secrets-access"
  role = aws_iam_role.ec2_wordpress.id

  policy = data.aws_iam_policy_document.secrets_policy.json
}

data "aws_iam_policy_document" "secrets_policy" {
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [var.db_secret_arn]
    effect    = "Allow"
  }
}

resource "aws_iam_instance_profile" "wordpress_instance_profile" {
  name = "${var.environment}-wordpress-instance-profile"
  role = aws_iam_role.ec2_wordpress.name
}

# IAM Role for Lambda@Edge Execution
resource "aws_iam_role" "lambda_edge_execution" {
  name = "${var.environment}-lambda-edge-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Custom logging policy for Lambda@Edge to CloudWatch Logs
resource "aws_iam_policy" "lambda_edge_logging" {
  name        = "${var.environment}-lambda-edge-logging-policy"
  description = "IAM policy for Lambda@Edge logging to CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Attach the custom logging policy to Lambda@Edge role
resource "aws_iam_role_policy_attachment" "lambda_edge_logging_attach" {
  policy_arn = aws_iam_policy.lambda_edge_logging.arn
  role       = aws_iam_role.lambda_edge_execution.name
}

# Attach AWS managed basic execution policy to Lambda@Edge role
resource "aws_iam_role_policy_attachment" "lambda_edge_basic_execution" {
  role       = aws_iam_role.lambda_edge_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
