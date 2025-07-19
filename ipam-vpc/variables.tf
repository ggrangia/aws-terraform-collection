variable "ipam_regions" {
  type    = list(string)
  default = ["eu-west-1"]
}

variable "secondary_private_cidr" {
  default = 2
  type    = number
}

variable "cidr_pool" {
  type    = string
  default = "10.64.0.0/10"
}
