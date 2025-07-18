variable "spoke_main_cidr" {
  type    = string
  default = "10.80.0.0/24" // subnets will be /24 3 /26 private, 3/28 tgw subs, 1 /26 public with 3 /28
}

variable "egress_main_cidr" {
  type    = string
  default = "10.80.1.64/26"
}

variable "egress_public_cidr" {
  type    = string
  default = "10.80.1.128/26"
}
