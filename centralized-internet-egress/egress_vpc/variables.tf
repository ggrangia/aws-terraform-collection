variable "main_cidr" {
  type = string
}

variable "public_cidr" {
  type = string
}

variable "transit_gateway_id" {
  type = string
}

variable "vpc_backroute_cidr" {
  type    = list(string)
  default = []
}