output "tgw_subnets" {
  value = [for s in aws_subnet.tgw_eni : s.id]
}

output "vpc" {
  value = aws_vpc.this
}

output "tgw_attachment" {
  value = aws_ec2_transit_gateway_vpc_attachment.tgw
}