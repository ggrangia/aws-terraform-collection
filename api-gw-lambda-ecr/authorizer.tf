resource "aws_ecr_repository" "authorizer" {
  name                 = "authorizer"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "docker_image" "authorizer" {
  name = aws_ecr_repository.authorizer.repository_url
  build {
    context = "./src/authorizer"
    tag     = local.authorizer_docker_full_names
  }

  triggers = {
    dir_sha = sha1(join("", [for f in fileset(path.module, "./src/authorizer/*") : filesha1(f)]))
  }
}

resource "docker_registry_image" "authorizer" {
  for_each = toset(local.authorizer_docker_full_names)

  name          = each.key
  keep_remotely = true # if true do not delete remotely
  depends_on    = [docker_image.authorizer]
}

module "authorizer" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.2.1"

  create         = true
  create_package = false

  publish = true

  function_name = "authorizer"
  description   = "My simple authorizer. You can pass with 50% probability!"

  timeout     = 30
  memory_size = 128

  attach_tracing_policy = true
  tracing_mode          = "Active"
  package_type          = "Image"
  image_uri             = "${aws_ecr_repository.authorizer.repository_url}:${var.git_sha}"


  environment_variables = {
    "POWERTOOLS_LOG_LEVEL" : "INFO",
    "POWERTOOLS_SERVICE_NAME" : "AUTHORIZER",
  }

  depends_on = [docker_registry_image.authorizer]
}
