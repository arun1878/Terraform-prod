output "elb_target_group_arn"{
  value = "${aws_lb_target_group.elb_tg.id}"
}

output "elb_target_group_name"{
  value = "${aws_lb_target_group.elb_tg.name}"
}