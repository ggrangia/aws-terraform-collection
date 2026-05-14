locals {
  private_cidrs      = [for k, v in var.azs : cidrsubnet(var.main_cidr_block, 4, k)]
  alb_internal_cidrs = [for k, v in var.azs : cidrsubnet(var.main_cidr_block, 6, k + (4 * length(var.azs)))]
  tgw_internal_cidrs = [for k, v in var.azs : cidrsubnet(var.main_cidr_block, 8, k + (20 * length(var.azs)))]
}

module "vpc" {
  source = "./modules/vpc"

  name                  = "my-vpc"
  cidr_block            = var.main_cidr_block
  secondary_cidr_blocks = var.secondary_cidr_blocks

  azs    = var.azs
  create = var.create_vpc

  subnet_groups = {
    public = {
      cidrs  = [for k, v in var.azs : cidrsubnet(var.secondary_cidr_blocks[0], 2, k)]
      public = true
    }
    workload = {
      cidrs       = local.private_cidrs
      public      = false
      nat_gateway = true
    }
    alb_internal = {
      cidrs       = local.alb_internal_cidrs
      public      = false
      nat_gateway = false
    }
    tgw_internal = {
      cidrs       = local.tgw_internal_cidrs
      public      = false
      nat_gateway = false
    }
  }
}
