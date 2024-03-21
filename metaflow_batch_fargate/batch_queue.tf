resource "aws_batch_job_queue" "metaflow_queue" {
  name     = "metaflow_queue"
  state    = "ENABLED"
  priority = 1

  compute_environment_order {
    order               = 1
    compute_environment = aws_batch_compute_environment.metaflow_compute_env.arn
  }

}
