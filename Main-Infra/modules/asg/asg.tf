resource "aws_autoscaling_group" "ASG" {
  lifecycle { create_before_destroy = true }
  vpc_zone_identifier = var.public_subnets
  name = "${var.service_name}-asg"
  max_size = "${var.asg_max}"
  min_size = "${var.asg_min}"
  wait_for_elb_capacity = 0
  force_delete = true
  launch_configuration = "${var.launch_config_name}"
  target_group_arns = ["${var.elb_target_group_arn}"]
  termination_policies = ["OldestInstance", "OldestLaunchConfiguration"]
  tag {
    key = "Name"
    value = "${var.tag_name}"
    propagate_at_launch = "true"
  }
  tag {
    key                 = "Monitor"
    value               = "Prometheus"
    propagate_at_launch = "true"
  }
  tag {
    key                 = "Environment"
    value               = "Production"
    propagate_at_launch = "true"
  }
}

#
# Scale Up Policy and Alarm
#
resource "aws_autoscaling_policy" "scale_up" {
  name = "asg_scale_up"
  scaling_adjustment = 2
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.ASG.name}"
}
resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name = "high-asg-cpu-${var.service_name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "80"
  insufficient_data_actions = []
  dimensions = {
      AutoScalingGroupName = "${aws_autoscaling_group.ASG.name}"
  }
  alarm_description = "EC2 CPU Utilization"
  alarm_actions = ["${aws_autoscaling_policy.scale_up.arn}"]
}

#
# Scale Down Policy and Alarm
#
resource "aws_autoscaling_policy" "scale_down" {
  name = "asg_scale_down"
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  cooldown = 600
  autoscaling_group_name = "${aws_autoscaling_group.ASG.name}"
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name = "low-asg-cpu-${var.service_name}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = "5"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "30"
  insufficient_data_actions = []
  dimensions = {
      AutoScalingGroupName = "${aws_autoscaling_group.ASG.name}"
  }
  alarm_description = "EC2 CPU Utilization"
  alarm_actions = ["${aws_autoscaling_policy.scale_down.arn}"]
}
output "asg_id" {
  value = "${aws_autoscaling_group.ASG.id}"
}
