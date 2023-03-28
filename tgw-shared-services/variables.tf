variable "transit_gateway_rt_names" {
  description = "List of strings containing the names of the transit gateway route tables"
  type        = list(string)
}

variable "acc1_vpc" {
  description = "VPCs tp be created on account 1"
  type        = any
}