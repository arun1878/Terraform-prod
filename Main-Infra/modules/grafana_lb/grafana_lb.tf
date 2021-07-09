resource "aws_lb_target_group" "grafana_tg" {
  name               = "Grafana-target-group"
  port     = 4000
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  load_balancing_algorithm_type = "least_outstanding_requests"
  stickiness {
    enabled = true
    type    = "lb_cookie"
  }
  health_check {
    healthy_threshold   = 2
    interval            = 30
    protocol            = "HTTP"
    unhealthy_threshold = 2
  }
  depends_on = [var.alb_name]
lifecycle {create_before_destroy = true}
}

resource "aws_lb_target_group_attachment" "grafana" {
  target_group_arn = aws_lb_target_group.grafana_tg.arn
  target_id        = var.aws_instance
  port             = 3000
}

resource "aws_alb_listener_rule" "listener_grafana_rule" {
  listener_arn = var.listener_arn  
  priority     = var.priority   
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana_tg.arn
  }
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
  condition {
    host_header {
      values = [var.host_header]
    }
  }
}