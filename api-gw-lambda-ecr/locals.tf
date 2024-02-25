locals {
  hello_api_image_name        = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${aws_ecr_repository.hello_api.name}"
  hello_api_docker_tags       = [var.git_sha, var.git_tag]
  hello_api_docker_full_names = [for t in local.hello_api_docker_tags : "${local.hello_api_image_name}:${t}"]
}
