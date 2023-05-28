
provider "aws" {
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
  alias      = "netmanager"
  access_key = ""
  secret_key = ""

  region = "us-west-2"

  default_tags {
    tags = {
      Environment = "Dev"
      Owner       = "ggrangia"
      Alias       = "netmanager"
    }
  }
}
