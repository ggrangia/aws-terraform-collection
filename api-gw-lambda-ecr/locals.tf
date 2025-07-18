locals {
  hello_api_image_name        = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.region}.amazonaws.com/${aws_ecr_repository.hello_api.name}"
  hello_api_docker_tags       = [for t in [var.git_sha, var.hello_api_tag] : t if t != ""]
  hello_api_docker_full_names = [for t in local.hello_api_docker_tags : "${local.hello_api_image_name}:${t}"]

  authorizer_image_name        = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.region}.amazonaws.com/${aws_ecr_repository.authorizer.name}"
  authorizer_docker_tags       = [for t in [var.git_sha, var.authorizer_tag] : t if t != ""]
  authorizer_docker_full_names = [for t in local.authorizer_docker_tags : "${local.authorizer_image_name}:${t}"]
}
