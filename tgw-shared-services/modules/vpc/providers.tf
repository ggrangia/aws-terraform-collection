terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.0"
      configuration_aliases = [aws.tgw]
    }
  }
  required_version = "~> 1.10"
}
