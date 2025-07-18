locals {
  escaped_domain_name = replace(var.private_domain, ".", "_")
  # name is also used as key
  extra_rules_name = [for r in var.extra_fwd_rules : r.name]
}
