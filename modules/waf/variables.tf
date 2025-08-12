variable "waf_name" {
  description = "Name of the WAF Web ACL"
  type        = string
}

variable "blocked_countries" {
  description = "List of ISO country codes to block (empty list disables country blocking)"
  type        = list(string)
  default     = []
}

variable "rate_limit" {
  description = "Optional rate limit (requests per 5 min) before blocking"
  type        = number
  default     = 2000
}

variable "environment" {
  description = "Environment label (e.g., global, irl-dev, sgp-dev)"
  type        = string
}

variable "aws_managed_rules" {
  description = "List of AWS managed rules to apply"
  type = list(object({
    name        = string
    priority    = number
    metric_name = string
  }))
  default = [
    {
      name        = "AWSManagedRulesCommonRuleSet"
      priority    = 0
      metric_name = "common-rule-set"
    },
    {
      name        = "AWSManagedRulesKnownBadInputsRuleSet"
      priority    = 1
      metric_name = "known-bad-inputs-rule-set"
    },
    {
      name        = "AWSManagedRulesSQLiRuleSet"
      priority    = 2
      metric_name = "sqli-rule-set"
    },
    {
      name        = "AWSManagedRulesLinuxRuleSet"
      priority    = 3
      metric_name = "linux-rule-set"
    }
  ]
}
