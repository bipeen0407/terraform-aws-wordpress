resource "aws_wafv2_web_acl" "this" {
  name  = var.waf_name
  scope = "CLOUDFRONT"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "web-acl-level-metrics"
    sampled_requests_enabled   = false
  }

  # Geo match rule to block traffic from specified countries (blacklist)
  dynamic "rule" {
    for_each = length(var.blocked_countries) > 0 ? [1] : []
    content {
      name     = "GeoBlockCountries"
      priority = 10000 # High priority to evaluate after managed and rate limit rules

      statement {
        geo_match_statement {
          country_codes = var.blocked_countries
        }
      }

      action {
        block {}
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "geo-blocked-countries"
        sampled_requests_enabled   = false
      }
    }
  }

  # Rate-based rule to limit requests per 5 minutes
  dynamic "rule" {
    for_each = var.rate_limit > 0 ? [1] : []
    content {
      name     = "RateLimitRule"
      priority = 9000

      statement {
        rate_based_statement {
          limit              = var.rate_limit
          aggregate_key_type = "IP"
        }
      }

      action {
        block {}
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "rate-limit-rule"
        sampled_requests_enabled   = false
      }
    }
  }

  # AWS Managed Rules - dynamically added
  dynamic "rule" {
    for_each = var.aws_managed_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority

      statement {
        managed_rule_group_statement {
          name        = rule.value.name
          vendor_name = "AWS"
        }
      }

      override_action {
        none {}
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value.metric_name
        sampled_requests_enabled   = false
      }
    }
  }

  tags = {
    Environment = var.environment
  }
}
