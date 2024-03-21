resource "aws_ecr_repository" "metaflow_example" {
  name                 = "metaflow_example"
  image_tag_mutability = "MUTABLE"
  # It is better because of the development iteration cycle.
  # Changing tag requires changing the metaflow/config.json

  image_scanning_configuration {
    scan_on_push = true
  }
}
