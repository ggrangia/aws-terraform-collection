output "vpc_id" {
  value = var.create ? aws_vpc.this[0].id : null
}

output "nat_gateways" {
  value = aws_nat_gateway.this
}

output "public_subnets" {
  value = aws_subnet.public
}

output "private_subnets" {
  value = aws_subnet.private
}
