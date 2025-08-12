# Create Origin Access Control
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.environment}-oac"
  description                       = "OAC for CloudFront to access S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_protocol                  = "sigv4"
  signing_behavior                  = "always"
}

resource "aws_cloudfront_distribution" "this" {
  enabled = true

  dynamic "origin" {
    for_each = var.origins
    content {
      domain_name              = origin.value.domain_name
      origin_id                = origin.value.origin_id
      origin_access_control_id = origin.value.origin_access_control_id

      dynamic "custom_origin_config" {
        for_each = contains(keys(origin.value), "custom_origin_config") && origin.value.custom_origin_config != null ? [1] : []
        content {
          http_port              = origin.value.custom_origin_config.http_port
          https_port             = origin.value.custom_origin_config.https_port
          origin_protocol_policy = origin.value.custom_origin_config.origin_protocol_policy
          origin_ssl_protocols   = origin.value.custom_origin_config.origin_ssl_protocols
        }
      }
    }
  }

  default_cache_behavior {
    target_origin_id       = var.default_cache_behavior_origin_id
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behaviors
    content {
      path_pattern           = ordered_cache_behavior.value.path_pattern
      target_origin_id       = ordered_cache_behavior.value.target_origin_id
      allowed_methods        = ordered_cache_behavior.value.allowed_methods
      cached_methods         = ordered_cache_behavior.value.cached_methods
      viewer_protocol_policy = ordered_cache_behavior.value.viewer_protocol_policy

      lambda_function_association {
        event_type   = ordered_cache_behavior.value.lambda_association_event
        lambda_arn   = ordered_cache_behavior.value.lambda_function_arn
        include_body = false
      }

      forwarded_values {
        query_string = ordered_cache_behavior.value.query_string_forward
        cookies {
          forward = ordered_cache_behavior.value.cookies_forward
        }
      }

      min_ttl     = ordered_cache_behavior.value.min_ttl
      default_ttl = ordered_cache_behavior.value.default_ttl
      max_ttl     = ordered_cache_behavior.value.max_ttl
    }
  }

  web_acl_id = var.waf_web_acl_arn

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none" # Geo restrictions handled by WAF
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Environment = var.environment
  }
}


