output "transit_gateway_id" {
  value = aws_ec2_transit_gateway.this.id
}

output "transit_gateway_arn" {
  value = aws_ec2_transit_gateway.this.arn
}

output "spoke_route_table" {
  value = aws_ec2_transit_gateway_route_table.spoke_vpc_rt
}

output "egress_route_table" {
  value = aws_ec2_transit_gateway_route_table.egress_vpc_rt
}

/*
output "tgw_ram_resource_association" {
  value = aws_ram_resource_association.tgw_org.id
}
output "tgw_ram_principal_association" {
  value = aws_ram_principal_association.tgw_org.id
}
*/