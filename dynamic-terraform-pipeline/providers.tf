provider "aws" {
  region = "eu-west-1"

  default_tags {
    tags = {
      Environment = "Dev"
      Owner       = "ggrangia"
      Alias       = "dynamic-terraform-pipeline"
    }
  }
}
