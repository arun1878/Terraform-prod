variable "instance_type" {}
variable "availability_zones" {}
variable "key_name" {}
variable "vol_size" {}
variable "vol_type" {}
variable "name" {}
variable "amis" {}
variable "public_subnets" {default = ""}
variable "private_subnets" {default = ""}
variable "security_group_ids" {}