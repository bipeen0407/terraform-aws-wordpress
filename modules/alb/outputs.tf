output "alb_arn" {
  description = "ARN of the ALB"
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "ALB Route53 hosted zone ID"
  value       = aws_lb.this.zone_id
}

output "http_listener_arn" {
  description = "ARN of the HTTP listener"
  value       = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener (if enabled)"
  value       = var.certificate_arn != "" ? aws_lb_listener.https[0].arn : null
}

output "target_group_arn" {
  value = aws_lb_target_group.this.arn
}
