variable "availability_zones" {
  default = ["us-west-2a","us-west-2b","us-west-2c"]
}


variable "https_inbound_sg_id" {default = ""}
variable "http_inbound_sg_id" {default = ""}
variable "vpc_id" {}
variable "asg_id" {}
variable "service_name" {}
variable "alb_name" {}
variable "host_header" {}
variable "priority" {}
variable "listener_arn" {}
variable "target_port" {}
