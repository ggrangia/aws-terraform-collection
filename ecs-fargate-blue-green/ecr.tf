
resource "aws_ecr_repository" "my_ecr" {
  name                 = "my_ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
