variable "git_sha" {
  description = "SHA value of the commit. This value comes from Github worflow."
  type        = string
}

variable "hello_api_tag" {
  type        = string
  description = "Hello API version tag to release. This value comes from Github worflow."
  default     = ""
  validation {
    condition     = can(regex("^v[0-9]+(.[0-9]+)*", var.hello_api_tag)) || var.hello_api_tag == ""
    error_message = "Wrong version format. Expected v1.2.3 or empty"
  }
}

variable "authorizer_tag" {
  type        = string
  description = "Authorizer version tag to release. This value comes from Github worflow."
  default     = ""
  validation {
    condition     = can(regex("^v[0-9]+(.[0-9]+)*", var.authorizer_tag)) || var.authorizer_tag == ""
    error_message = "Wrong version format. Expected v1.2.3 or empty"
  }
}
