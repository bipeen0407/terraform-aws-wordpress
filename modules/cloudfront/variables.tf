variable "origins" {
  description = "List of origins with domain, origin_id, OAC, and optional custom config"
  type = list(object({
    domain_name              = string
    origin_id                = string
    origin_access_control_id = string
    custom_origin_config = optional(object({
      http_port              = number
      https_port             = number
      origin_protocol_policy = string
      origin_ssl_protocols   = list(string)
    }))
  }))
}

variable "default_cache_behavior_origin_id" {
  description = "Origin ID for default cache behavior"
  type        = string
}

variable "ordered_cache_behaviors" {
  description = "List of additional cache behaviors for routing by path patterns"
  type = list(object({
    path_pattern             = string
    target_origin_id         = string
    allowed_methods          = list(string)
    cached_methods           = list(string)
    viewer_protocol_policy   = string
    lambda_function_arn      = string
    lambda_association_event = string
    query_string_forward     = bool
    cookies_forward          = string
    min_ttl                  = number
    default_ttl              = number
    max_ttl                  = number
  }))
  default = []
}

variable "web_acl_id" {
  description = "WAF Web ACL ID to associate with CloudFront"
  type        = string
}

variable "environment" {
  description = "Environment tag for resources"
  type        = string
}
