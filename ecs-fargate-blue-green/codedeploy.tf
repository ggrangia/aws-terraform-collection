resource "aws_codedeploy_app" "client" {
  compute_platform = "ECS"
  name             = "client_app"
}

resource "aws_codedeploy_deployment_config" "client_config" {
  deployment_config_name = "client_app"
  compute_platform       = "ECS"

  traffic_routing_config {
    type = "AllAtOnce"
  }
}

resource "aws_codedeploy_deployment_group" "client_deployment_group" {
  app_name               = aws_codedeploy_app.client.name
  deployment_config_name = aws_codedeploy_deployment_config.client_config.deployment_config_name
  deployment_group_name  = "client_app"
  service_role_arn       = aws_iam_role.codedeploy.arn

  ecs_service {
    cluster_name = aws_ecs_cluster.mycluster.name
    service_name = aws_ecs_service.client_service.name
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout    = "CONTINUE_DEPLOYMENT"
      wait_time_in_minutes = 0
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  load_balancer_info {
    target_group_pair_info {
      target_group {
        name = aws_lb_target_group.client.name
      }

      target_group {
        name = aws_lb_target_group.client2.name
      }

      prod_traffic_route {
        listener_arns = [aws_lb_listener.client_listener.arn]
      }


      test_traffic_route {
        listener_arns = [aws_lb_listener.client2_listener.arn]
      }
    }
  }

}
