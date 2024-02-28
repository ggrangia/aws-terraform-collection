variable "git_sha" {
  type = string
}

variable "hello_api_tag" {
  type = string
  validation {
    condition     = can(regex("^v[0-9]+(.[0-9]+)*", var.hello_api_tag))
    error_message = "Wrong version format. Expected v1.2.3"
  }
}

variable "authorizer_tag" {
  type = string
  validation {
    condition     = can(regex("^v[0-9]+(.[0-9]+)*", var.authorizer_tag))
    error_message = "Wrong version format. Expected v1.2.3"
  }
}
