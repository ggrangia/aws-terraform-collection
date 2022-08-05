
locals {
  vpc_cidr_blocks = concat([aws_vpc.test.cidr_block], aws_vpc_ipv4_cidr_block_association.secondary_cidr[*].cidr_block)
  subnets_az      = zipmap(data.aws_availability_zones.available.names, local.vpc_cidr_blocks)
}
