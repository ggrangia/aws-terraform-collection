locals {
  main_cidr      = "10.0.0.0/22"
  secondary_cidr = "10.100.0.0/26"
  vpc_azs        = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  version = "v6.0.1"
  name    = "my-vpc"

  create_vpc = true

  cidr                  = local.main_cidr
  secondary_cidr_blocks = [local.secondary_cidr]

  azs             = local.vpc_azs
  private_subnets = [for k, v in local.vpc_azs : cidrsubnet(local.main_cidr, 2, k)]
  public_subnets  = [for k, v in local.vpc_azs : cidrsubnet(local.secondary_cidr, 2, k)]

  enable_vpn_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  # One NAT per az
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true
}
