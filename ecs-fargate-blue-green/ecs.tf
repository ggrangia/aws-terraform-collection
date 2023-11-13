
resource "aws_cloudwatch_log_group" "myclusterlg" {
  name = "myclusterlg"
}


resource "aws_ecs_cluster" "mycluster" {
  name = "mycluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.myclusterlg.name
      }
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "fargate" {
  cluster_name = aws_ecs_cluster.mycluster.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
}
