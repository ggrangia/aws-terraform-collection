output "tgw_subnets" {
  value = [for s in aws_subnet.tgw_eni : s.id]
}

output "vpc" {
  value = aws_vpc.this
}

output "public_rt" {
  value = aws_route_table.public
}

output "private_rt" {
  value = aws_route_table.private
}

output "tgw_vpc_attachment_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.egress_tgw.id
}
