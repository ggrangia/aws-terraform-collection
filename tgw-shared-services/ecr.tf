// Deployed in the same account and region as the TGW
resource "aws_ecr_repository" "tgw_operations" {
  name                 = "tgw_operations"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
