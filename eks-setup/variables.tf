variable "main_cidr_block" {
  type    = string
  default = "10.0.0.0/20"
}

variable "azs" {
  description = "List of AZs"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "create_vpc" {
  description = "Whether to create the VPC"
  type        = bool
  default     = true
}

variable "secondary_cidr_blocks" {
  description = "Additional CIDR blocks for the VPC"
  type        = list(string)
  default     = ["10.100.0.0/26"]
}
