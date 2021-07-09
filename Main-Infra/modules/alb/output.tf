output "alb_arn" {
  value = aws_lb.alb.arn
}
output "alb_name" {
  value = aws_lb.alb.name
}
output "alb_listener" {
  value = aws_lb_listener.alb_listener.arn
}