
provider "aws" {
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
