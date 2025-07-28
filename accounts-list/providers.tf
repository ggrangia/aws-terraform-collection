terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 6.0"
      configuration_aliases = [aws.org, aws.target]
    }
  }
  required_version = "~> 1.10"
}

provider "aws" {
  region = "us-east-1"
  alias  = "org"

  default_tags {
    tags = {
      Environment = "Dev"
      Owner       = "ggrangia"
      Project     = "accounts-list"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "target"

  default_tags {
    tags = {
      Environment = "Dev"
      Owner       = "ggrangia"
      Project     = "accounts-list"
    }
  }
}
