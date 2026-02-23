variable "transit_gateway_rt_names" {
  description = "List of strings containing the names of the transit gateway route tables"
  type        = list(string)
}

variable "private_asn" {
  type        = number
  description = "The private ASN for the Amazon side of a BGP session (64512 to 65534 32 bits or 4200000000 to 4294967294 64 bits)"
}
