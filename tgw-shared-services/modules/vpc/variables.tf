
variable "name" {
  type = string
}

variable "cidr" {
  type = string
}

variable "type" {
  type        = string
  description = "VPC Type. Use for Transit gateway propagations and route table attachments"
}

variable "tgw_asn" {
  type = number
}
