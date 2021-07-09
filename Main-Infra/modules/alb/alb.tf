resource "aws_lb" "alb" {
  name               = var.name
  load_balancer_type = "application"
  enable_cross_zone_load_balancing = true
  subnets            = var.public_subnets[0]
  security_groups    = ["${var.alb_sg_id}"]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.cert_arn
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = var.content_type
      message_body = var.message_body
      status_code  = var.status_code
    }
  }
}
