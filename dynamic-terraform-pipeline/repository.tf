resource "aws_codecommit_repository" "myrepo1" {
  repository_name = var.repository_name1
  description     = "This firest repository is used to trigger the dynamic pipeline"
  default_branch  = "main"
}

resource "aws_codecommit_repository" "myrepo2" {
  repository_name = var.repository_name2
  description     = "This second repository is used to trigger the dynamic pipeline"
  default_branch  = "main"
}
