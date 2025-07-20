variable "main_cidr" {
  type = string
}

variable "public_cidr" {
  type = string
}

variable "transit_gateway_id" {
  type = string
}

variable "tgw_ram_id" {
  type = string
}

variable "subnets_number" {
  type    = number
  default = 3
  validation {
    error_message = "Value must be a positive integer and less then or equal to 5 (check azs in your region)"
    condition     = var.subnets_number > 0 && var.subnets_number <= 6 && (floor(var.subnets_number) == var.subnets_number)
  }
}
