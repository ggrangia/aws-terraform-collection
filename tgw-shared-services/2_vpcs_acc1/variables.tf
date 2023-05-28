variable "vpcs" {
  description = "VPCs to be created"
  type = map(object({
    cidr = string,
    type = string,
  }))
}

variable "tgw_asn" {
  type = number
}
