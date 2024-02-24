variable "git_tag" {
  type        = string
  description = "Semver tag coming from the repository tags. e.g: v1.2.0"

  validation {
    condition     = can(regex("^v[0-9]+(.[0-9]+)*", var.git_tag))
    error_message = "Wrong version format. Expected v1.2.3"
  }
}


variable "git_sha" {
  type = string
}
