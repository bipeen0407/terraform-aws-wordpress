output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.wordpress.id
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.wordpress_asg.name
}
