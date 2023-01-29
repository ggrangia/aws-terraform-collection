locals {
  escaped_domain_name = replace(var.private_domain, ".", "_")
}