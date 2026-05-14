variable "create" {
  description = "Whether to create resources"
  type        = bool
  default     = true
}

variable "name" {
  type = string
}

variable "cidr_block" {
  type    = string
  default = "10.0.0.0/20"
}

variable "azs" {
  description = "List of AZs"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "subnet_groups" {
  description = <<EOF
Map of subnet groups.

Example:
{
  public = {
    cidrs  = ["10.0.1.0/24", "10.0.2.0/24"],
    public = true
  }
  private = {
    cidrs  = ["10.0.10.0/24", "10.0.11.0/24"],
    public = false
  }
}
EOF

  type = map(object({
    cidrs       = list(string)
    public      = optional(bool, false)
    nat_gateway = optional(bool, false)
  }))
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "secondary_cidr_blocks" {
  description = "Additional CIDR blocks for the VPC"
  type        = list(string)
  default     = []
}
