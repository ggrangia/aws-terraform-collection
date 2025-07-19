variable "private_domain" {
  type    = string
  default = "mydomain.mycloud"
}

variable "extra_fwd_rules" {
  type = list(object({
    name   = string
    domain = string
    ip     = list(string)
  }))
  default = [
    {
      name   = "other_domain"
      domain = "other.domain"
      ip = [
        "35.53.11.110",
        "35.53.12.110"
      ]
    },
    {
      name   = "another_domain"
      domain = "another.domain"
      ip = [
        "1.1.1.1",
        "2.2.2.2"
      ]
    }
  ]
}
