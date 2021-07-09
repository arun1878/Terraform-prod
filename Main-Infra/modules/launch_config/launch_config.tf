resource "aws_launch_configuration" "launch_config" {
  lifecycle { create_before_destroy = true }
  image_id = "${var.amis}"
  instance_type = "${var.instance_type}"
  iam_instance_profile = var.iam_instance_profile
  security_groups = [
    "${var.https_inbound_sg_id}",
    "${var.ssh_sg_id}",
    "${var.node_sg_id}"
  ]
  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp2"
    delete_on_termination = true
    }
  key_name = "${var.key_name}"
  associate_public_ip_address = true
  name  = "Launch-conf-${var.service_name}"
  user_data = <<EOF
#!/bin/bash
sudo aws s3 cp s3://prod-purmo-config/${var.SERVICE}/amazon-cloudwatch-agent.json /opt
sudo mv /opt/amazon-cloudwatch-agent.json /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
EOF
}
output "launch_config_id" {
  value = "${aws_launch_configuration.launch_config.id}"
}
output "launch_config_name" {
  value = "${aws_launch_configuration.launch_config.name}"
}
