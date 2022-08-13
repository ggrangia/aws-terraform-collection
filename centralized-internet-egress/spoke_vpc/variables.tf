variable "main_cidr" {
  type = string // subnets will be /24 3 /26 private, 3/28 tgw subs, 
}

variable "transit_gateway_id" {
  type = string
}

variable "name" {
  type = string
}