variable "availability_zones" {
  default = ["us-west-2a","us-west-2b","us-west-2c"]
}
variable "asg_min" {}
variable "asg_max" {}
#
# From other modules
#
variable "public_subnets" {}
variable "launch_config_id" {}
variable "launch_config_name" {}
variable "elb_target_group_arn" {}
variable "service_name" {}
variable "tag_name" {}