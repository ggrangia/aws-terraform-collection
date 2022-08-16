
locals {
  std_vpc_name = "${var.name}-spoke"

  pvt_subnets    = [for i in range(length(data.aws_availability_zones.available.names)) : cidrsubnet(aws_vpc.this.cidr_block, 2, i)]
  subnets_az     = zipmap(data.aws_availability_zones.available.names, local.pvt_subnets)
  tgw_cidr       = cidrsubnet(aws_vpc.this.cidr_block, 2, 3) // /26
  tgw_subnets    = [for i in range(length(data.aws_availability_zones.available.names)) : cidrsubnet(local.tgw_cidr, 2, i)]
  tgw_subnets_az = zipmap(data.aws_availability_zones.available.names, local.tgw_subnets)
}
