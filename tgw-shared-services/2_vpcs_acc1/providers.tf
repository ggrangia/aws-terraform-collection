terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = "~> 1.10"
}

provider "aws" {
  region = "eu-west-1"

  default_tags {
    tags = {
      Environment = "Dev"
      Owner       = "ggrangia"
      Alias       = "account1"
    }
  }
}

provider "aws" {
  alias = "tgw"

  region = "eu-west-1"

  default_tags {
    tags = {
      Environment = "Dev"
      Owner       = "ggrangia"
      Alias       = "tgw"
    }
  }
}
