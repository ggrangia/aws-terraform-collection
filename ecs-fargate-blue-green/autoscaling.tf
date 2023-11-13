
resource "aws_appautoscaling_target" "ecs_client" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.mycluster.name}/${aws_ecs_service.client_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}


resource "aws_appautoscaling_policy" "ecs_client" {
  name               = "client-scale-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_client.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_client.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_client.service_namespace


  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 60
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}
