terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  required_version = "~> 1.10"
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = "Dev"
      Owner       = "ggrangia"
      Alias       = "vpc"
    }
  }
}

provider "aws" {
  alias = "tgw"

  region = "us-east-1"

  default_tags {
    tags = {
      Environment = "Dev"
      Owner       = "ggrangia"
      Alias       = "tgw"
    }
  }
}
