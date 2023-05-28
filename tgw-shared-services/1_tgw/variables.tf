variable "transit_gateway_rt_names" {
  description = "List of strings containing the names of the transit gateway route tables"
  type        = list(string)
}

variable "private_asn" {
  type        = number
  description = "The private ASN for the Amazon side of a BGP session"
}
