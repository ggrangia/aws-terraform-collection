variable "private_network_cidr" {
  default = "10.0.0.0/8"
}

variable "private_domain" {
  default = "mydomain.mycloud"
}

variable "extra_fwd_rules" {
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
