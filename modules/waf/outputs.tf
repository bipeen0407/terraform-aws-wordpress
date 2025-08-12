output "web_acl_id" {
  value       = aws_wafv2_web_acl.this.id
  description = "The ID of the WAF Web ACL associated with the CloudFront distribution."
}
