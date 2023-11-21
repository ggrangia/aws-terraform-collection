resource "aws_ecs_service" "client_service" {
  name            = "client_service"
  cluster         = aws_ecs_cluster.mycluster.id
  task_definition = aws_ecs_task_definition.client.arn
  desired_count   = 2


  deployment_controller {
    type = "CODE_DEPLOY"
  }


  load_balancer {
    target_group_arn = aws_lb_target_group.client.arn
    container_name   = "client" // as it appears in a container definition
    container_port   = 9090     # fake_Service
    # container_port = 80 # nginx
  }

  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.alb_sg.id]
    assign_public_ip = false
  }

  // For each FARGATE instance, 2 FARGATE_SPOT are created
  // At least 1 FARGATE (base)
  // Use 10, 20 etc for percentage
  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 0
    base              = 1
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 100
  }

  lifecycle {
    // because of autoscaling, codedeploy blue/green deployments
    ignore_changes = [task_definition, load_balancer, desired_count, capacity_provider_strategy]
  }

  // iam_role        = aws_iam_role.client_task_role.arn
  // depends_on = [aws_iam_policy.client_task_policy]
}
