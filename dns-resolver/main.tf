// This vpc will hold the DNS endpoint
module "main_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v5.21.0"

  name                  = "main_vpc"
  cidr                  = "10.0.0.0/24"
  secondary_cidr_blocks = ["100.64.0.0/26"]

  azs = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  # 10.0.0.0/24, spare: 10.0.0.192/26
  private_subnets = ["10.0.0.0/26", "10.0.0.64/26", "10.0.0.128/26"]
  # Public is non-routable in our network
  # 100.64.0.0/26, spare: 100.64.0.48/28
  public_subnets = ["100.64.0.0/28", "100.64.0.16/28", "100.64.0.32/28"]

  enable_nat_gateway   = true
  enable_dns_hostnames = true
}

resource "aws_security_group" "dns" {
  name        = "allow_dns"
  description = "Allow DNS inbound traffic"
  vpc_id      = module.main_vpc.vpc_id
}

resource "aws_security_group_rule" "dns_tcp_ingr" {
  type              = "ingress"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.dns.id
}

resource "aws_security_group_rule" "dns_udp_ingr" {
  type              = "ingress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.dns.id
}

resource "aws_security_group_rule" "dns_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.dns.id
}

resource "aws_route53_resolver_endpoint" "inbound" {
  name      = "inbound_${local.escaped_domain_name}"
  direction = "INBOUND"

  security_group_ids = [aws_security_group.dns.id]

  dynamic "ip_address" {
    for_each = module.main_vpc.private_subnets
    content {
      subnet_id = ip_address.value
    }
  }

  tags = {
    Domain = var.private_domain
  }
}

resource "aws_route53_resolver_endpoint" "outbound" {
  name      = "outbound_${local.escaped_domain_name}"
  direction = "OUTBOUND"

  security_group_ids = [aws_security_group.dns.id]

  dynamic "ip_address" {
    for_each = module.main_vpc.private_subnets
    content {
      subnet_id = ip_address.value
    }
  }

  tags = {
    Domain = var.private_domain
  }
}

resource "aws_route53_resolver_rule" "mydomain" {
  domain_name          = var.private_domain
  name                 = "mydomain"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound.id

  // Forwarding all the dns queries for [my custom domain] towards the IPs of
  // my Inbound enpoint. In this way, it is like forwarding it to the .2
  // resolver of the VPC.
  dynamic "target_ip" {
    for_each = { for ip in aws_route53_resolver_endpoint.inbound.ip_address : ip.ip => ip }
    content {
      ip   = target_ip.value.ip
      port = 53
    }
  }
}

resource "aws_route53_resolver_rule" "extra" {
  for_each             = { for rule in var.extra_fwd_rules : rule.name => rule }
  domain_name          = each.value.domain
  name                 = each.value.name
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound.id

  dynamic "target_ip" {
    for_each = toset(each.value.ip)
    content {
      ip   = target_ip.value
      port = 53
    }
  }
}

// IMPORTANT: no need to associate my "main" domain resover rule with
// the VPC where the Endpoints are hosted

resource "aws_route53_resolver_rule_association" "extra" {
  for_each = { for rule in var.extra_fwd_rules : rule.name => rule }

  resolver_rule_id = aws_route53_resolver_rule.extra[each.value.name].id
  vpc_id           = module.main_vpc.vpc_id

  depends_on = [
    aws_route53_resolver_rule.extra,
  ]
}
