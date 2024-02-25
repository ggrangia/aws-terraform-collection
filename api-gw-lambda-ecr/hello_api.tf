resource "aws_ecr_repository" "hello_api" {
  name                 = "hello_api"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "docker_image" "hello_api" {
  name = local.hello_api_image_name
  build {
    context = "./hello_api"
    tag     = local.hello_api_docker_full_names
  }

  triggers = {
    # TODO: check multiple conditions
    #dir_sha = sha1(join("", [for f in fileset(path.module, "hello_api/*") : filesha1(f)]))
    time = timestamp()
  }
}

resource "docker_registry_image" "hello_api" {
  for_each = toset(local.hello_api_docker_full_names)

  name          = each.key
  keep_remotely = true # if true do not delete remotely
  depends_on    = [docker_image.hello_api]
}

module "hello_api" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.2.1"

  create         = true
  create_package = false

  publish = true

  function_name = "hello_api"
  description   = "MY simple code"

  timeout     = 30
  memory_size = 128
  #ephemeral_storage_size = 1024


  attach_tracing_policy = true
  tracing_mode          = "Active"
  package_type          = "Image"
  image_uri             = "${aws_ecr_repository.hello_api.repository_url}:${var.git_tag}"

  #attach_policy_json = true
  #policy_json        = data.aws_iam_policy_document.hello_api.json

  environment_variables = {
    "POWERTOOLS_LOG_LEVEL" : "INFO",
    "POWERTOOLS_SERVICE_NAME" : "HELLO_API_V1",
  }

  depends_on = [docker_registry_image.hello_api]
}

// Always refresh the alias -> similar to latest
module "alias_prd" {
  source = "terraform-aws-modules/lambda/aws//modules/alias"

  refresh_alias = true

  name = "prd"

  function_name    = module.hello_api.lambda_function_name
  function_version = module.hello_api.lambda_function_version
}

