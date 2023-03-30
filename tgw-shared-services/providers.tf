provider "aws" {
  access_key = ""
  secret_key = ""

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
  alias      = "tgw"
  access_key = ""
  secret_key = ""

  region = "eu-west-1"

  default_tags {
    tags = {
      Environment = "Dev"
      Owner       = "ggrangia"
      Alias       = "tgw"
    }
  }
}

provider "aws" {
  alias      = "account1"
  access_key = ""
  secret_key = ""

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
  alias      = "account2"
  access_key = ""
  secret_key = ""

  region = "eu-west-1"

  default_tags {
    tags = {
      Environment = "Dev"
      Owner       = "ggrangia"
      Alias       = "account2"
    }
  }
}