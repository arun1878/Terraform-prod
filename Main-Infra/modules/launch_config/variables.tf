variable "volume_size" {
  default = 60
}
variable "key_name" {}
variable "instance_type" {}
variable "amis" {}
#
# From other modules
#
variable "https_inbound_sg_id" {
  default = ""
}
variable "ssh_sg_id" {}
variable "node_sg_id" {}
variable "public_subnets" {}
variable "private_subnets" {}
variable "service_name" {}
variable "grafana_sg_id" {default = ""}
variable "iam_instance_profile" {}
variable "SERVICE" {}