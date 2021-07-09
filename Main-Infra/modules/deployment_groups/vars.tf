variable "aws_lb_target_group_name" {}
variable "aws_lb_target_group" {}
variable "service_name" {}
variable "autoscaling_groups" {}

variable "deployment_config_name" {
  description = "Deployment config name."
  default     = "CodeDeployDefault.OneAtATime"
}

variable "codedeploy_service_role" {}
variable "environment" {}
variable "codedeploy_app" {}
variable "traffic_control" {
  default = "WITHOUT_TRAFFIC_CONTROL"
}