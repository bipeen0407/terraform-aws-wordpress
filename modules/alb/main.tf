# Create Application Load Balancer
resource "aws_lb" "this" {
  name               = "${var.alb_name}-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.alb_security_groups
  subnets            = var.public_subnet_ids

  tags = {
    Name        = "${var.alb_name}-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "this" {
  name     = "${var.alb_name}-${var.environment}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Environment = var.environment
    Name        = "${var.alb_name}-${var.environment}-tg"
  }
}


# Create HTTP Listener (redirect to HTTPS if certificate provided)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
  # default_action {
  #   type = var.certificate_arn != "" ? "redirect" : "fixed-response"
  #   redirect {
  #     port        = "443"
  #     protocol    = "HTTPS"
  #     status_code = "HTTP_301"
  #   }
  #   fixed_response {
  #     content_type = "text/plain"
  #     message_body = "HTTPS required"
  #     status_code  = "403"
  #   }
  # }
}

# Create HTTPS Listener only if a certificate ARN is provided
resource "aws_lb_listener" "https" {
  count             = var.certificate_arn != "" ? 1 : 0
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Default HTTPS Listener Response"
      status_code  = "200"
    }
  }
}
