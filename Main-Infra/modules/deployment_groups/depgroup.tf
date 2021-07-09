# CodeDeploy Deployment Group
resource "aws_codedeploy_deployment_group" "codedeploy" {
  app_name               = var.codedeploy_app
  deployment_group_name  = "${var.environment}-${var.codedeploy_app}-${var.service_name}"
  deployment_config_name = var.deployment_config_name
  service_role_arn       = var.codedeploy_service_role
  autoscaling_groups     = [var.autoscaling_groups]
  deployment_style {
    deployment_option = var.traffic_control
  }
  load_balancer_info {
    target_group_info {
      name = var.aws_lb_target_group_name
            }
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.aws_lb_target_group]
      }

      target_group {
        name = var.aws_lb_target_group_name
      }

      target_group {
        name = var.aws_lb_target_group_name
      }
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}
