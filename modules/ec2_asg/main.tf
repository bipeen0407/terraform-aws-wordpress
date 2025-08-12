# Launch Template for WordPress EC2 configuration
resource "aws_launch_template" "wordpress" {
  name_prefix          = "${var.environment}-wordpress-lt"
  image_id             = var.ami_id
  instance_type        = var.instance_type
  security_group_names = [var.ec2_security_group]
  iam_instance_profile {
    name = var.instance_profile_name
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh.tpl", {
    efs_id        = var.efs_id
    db_name       = var.db_name
    db_user       = var.db_user
    db_host       = var.db_host
    db_secret_arn = var.db_secret_arn
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Environment = var.environment
      Role        = "WordPress"
    }
  }
}

# Auto Scaling Group for WordPress servers
resource "aws_autoscaling_group" "wordpress_asg" {
  name             = "${var.environment}-wordpress-asg"
  max_size         = var.asg_max_size
  min_size         = var.asg_min_size
  desired_capacity = var.asg_desired_capacity
  launch_template {
    id      = aws_launch_template.wordpress.id
    version = "$Latest"
  }
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [var.target_group_arn]
  health_check_type   = "ELB"
  tag {
    key                 = "Name"
    value               = "${var.environment}-wordpress"
    propagate_at_launch = true
  }
}

# Scale Out Policy
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${var.environment}-scale-out"
  autoscaling_group_name = aws_autoscaling_group.wordpress_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 180
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.environment}-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Scale out if CPU > 70%"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.wordpress_asg.name
  }
  alarm_actions = [aws_autoscaling_policy.scale_out.arn]
}

# Scale In Policy
resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${var.environment}-scale-in"
  autoscaling_group_name = aws_autoscaling_group.wordpress_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 180
}

resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "${var.environment}-low-cpu"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 30
  alarm_description   = "Scale in if CPU < 30%"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.wordpress_asg.name
  }
  alarm_actions = [aws_autoscaling_policy.scale_in.arn]
}

