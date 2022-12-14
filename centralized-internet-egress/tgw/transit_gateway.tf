resource "aws_ec2_transit_gateway" "this" {

  description = "TGW"

  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  amazon_side_asn = 64512 # specify different asn in case you want to use multiple TGW
}

resource "aws_ec2_transit_gateway_route_table" "spoke_vpc_rt" {

  transit_gateway_id = aws_ec2_transit_gateway.this.id

  tags = {
    Name = "Spoke VPC RT"
  }
}

resource "aws_ec2_transit_gateway_route_table" "egress_vpc_rt" {

  transit_gateway_id = aws_ec2_transit_gateway.this.id

  tags = {
    Name = "Egress VPC RT"
  }
}
