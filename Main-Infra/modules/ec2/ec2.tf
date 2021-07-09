resource "aws_instance" "EC2" {
    ami = "${var.amis}"
    instance_type = "${var.instance_type}"
    availability_zone = var.availability_zones[0]
    key_name = var.key_name
    ebs_block_device {
      device_name = "/dev/sdf"
      volume_size = var.vol_size
      volume_type = var.vol_type
      delete_on_termination = false
   }
   subnet_id = var.public_subnets[0]
   vpc_security_group_ids = var.security_group_ids
     tags = {
         Name = var.name
         Monitor = "Prometheus"
         Environmet = "Production"
      }
}

output "aws_instance" {
  value = "${aws_instance.EC2.id}"
}
