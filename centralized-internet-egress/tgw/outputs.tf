output "transit_gateway" {
  value = aws_ec2_transit_gateway.this
}

output "spoke_route_table" {
  value = aws_ec2_transit_gateway_route_table.spoke_vpc_rt
}

output "egress_route_table" {
  value = aws_ec2_transit_gateway_route_table.egress_vpc_rt
}