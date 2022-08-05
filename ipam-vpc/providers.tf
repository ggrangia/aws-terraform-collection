provider "aws" {
  access_key = "test"
  secret_key = "test"

  region = "eu-west-1"

  default_tags {
    tags = {
      Environment = "Dev"
      Owner       = "ggrangia"
      Alias       = "vpc"
    }
  }
}

provider "aws" {
  alias      = "ipam"
  access_key = "test"
  secret_key = "test"

  region = "eu-west-1"

  default_tags {
    tags = {
      Environment = "Dev"
      Owner       = "ggrangia"
      Alias       = "ipam"
    }
  }
}
