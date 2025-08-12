# S3 Bucket for static storage
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = {
    Environment = var.environment
    Name        = var.bucket_name
  }
}

# Enable versioning, if desired
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

# Cross-Region Replication configuration (only if ARNs provided)
resource "aws_s3_bucket_replication_configuration" "this" {
  count = var.replication_bucket_arn != "" && var.replication_role_arn != "" ? 1 : 0

  bucket = aws_s3_bucket.this.id
  role   = var.replication_role_arn

  rule {
    id     = "${var.environment}-crr"
    status = "Enabled"

    filter {
      prefix = ""
    }

    destination {
      bucket        = var.replication_bucket_arn
      storage_class = "STANDARD"
    }

    delete_marker_replication {
      status = "Enabled"
    }
  }
}

# Block all public access to the bucket
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enforce Bucket Owner Ownership (BucketOwnerEnforced)
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# S3 Bucket Policy to allow CloudFront access with Origin Access Control (OAC)
resource "aws_s3_bucket_policy" "cloudfront_oac_policy" {
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServiceReadOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.this.arn}/*"
        Condition = var.cloudfront_distribution_arn != "" ? {
          StringEquals = {
            "AWS:SourceArn" = var.cloudfront_distribution_arn
          }
        } : null
      }
    ]
  })
}
