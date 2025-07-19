
locals {
  pvt_subnets = [for i in range(length(data.aws_availability_zones.available.names)) : cidrsubnet(aws_vpc.this.cidr_block, 2, i)]
  subnets_az  = zipmap(data.aws_availability_zones.available.names, local.pvt_subnets)
}
