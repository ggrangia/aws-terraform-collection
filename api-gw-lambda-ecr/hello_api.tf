resource "aws_ecr_repository" "hello_api" {
  name                 = "hello_api"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "docker_image" "hello_api" {
  name = aws_ecr_repository.hello_api.repository_url
  build {
    context = "./src/hello_api"
    tag     = local.hello_api_docker_full_names
  }

  triggers = {
    dir_sha = sha1(join("", [for f in fileset(path.module, "./src/hello_api/*") : filesha1(f)]))
  }
}

resource "docker_registry_image" "hello_api" {
  for_each = toset(local.hello_api_docker_full_names)

  name          = each.key
  keep_remotely = true
  depends_on    = [docker_image.hello_api]
}

module "hello_api" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.0.1"

  create         = true
  create_package = false

  publish = true

  function_name = "hello_api"
  description   = "MY simple code"

  timeout     = 30
  memory_size = 128


  attach_tracing_policy = true
  tracing_mode          = "Active"
  package_type          = "Image"

  image_uri = "${aws_ecr_repository.hello_api.repository_url}:${var.git_sha}"


  environment_variables = {
    "POWERTOOLS_LOG_LEVEL" : "INFO",
    "POWERTOOLS_SERVICE_NAME" : "HELLO_API_V1",
  }

  depends_on = [docker_registry_image.hello_api]
}

resource "aws_lambda_alias" "hello_api_prd" {
  name = "prd"

  function_name    = module.hello_api.lambda_function_name
  function_version = module.hello_api.lambda_function_version

  lifecycle {
    // Create the alias
    ignore_changes = [function_version]
  }
}

module "hello_api_deployment" {
  source = "./modules/lambda_alias_deployment"

  lambda_name = module.hello_api.lambda_function_name
}
