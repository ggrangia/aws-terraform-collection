
locals {

  azs_min = min(length(data.aws_availability_zones.available.names), var.subnets_number)
  azs     = slice(data.aws_availability_zones.available.names, 0, local.azs_min)

  pvt_subnets = [for i in range(length(local.azs)) : cidrsubnet(aws_vpc.this.cidr_block, 2, i)]
  subnets_az  = zipmap(local.azs, local.pvt_subnets)
}
