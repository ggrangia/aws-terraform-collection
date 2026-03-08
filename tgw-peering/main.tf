data "aws_availability_zones" "available" {}
data "aws_availability_zones" "available_aws2" {
  region = "us-west-2"
}

locals {
  name1 = "vpc1"
  name2 = "vpc2"

  vpc1_cidr = "10.0.0.0/16"
  vpc2_cidr = "10.1.0.0/16"
  azs       = slice(data.aws_availability_zones.available.names, 0, 3)
  azs2      = slice(data.aws_availability_zones.available_aws2.names, 0, 3)
}

module "vpc1" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.name1
  cidr = local.vpc1_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc1_cidr, 8, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc1_cidr, 8, k + 4)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc1_cidr, 8, k + 8)]


  single_nat_gateway = true
  enable_nat_gateway = true
}

module "vpc2" {
  source = "terraform-aws-modules/vpc/aws"

  region = "us-west-2"

  name = local.name2
  cidr = local.vpc2_cidr


  azs             = local.azs2
  private_subnets = [for k, v in local.azs2 : cidrsubnet(local.vpc2_cidr, 8, k)]
  public_subnets  = [for k, v in local.azs2 : cidrsubnet(local.vpc2_cidr, 8, k + 4)]
  intra_subnets   = [for k, v in local.azs2 : cidrsubnet(local.vpc2_cidr, 8, k + 8)]


  single_nat_gateway = true
  enable_nat_gateway = true
}


resource "aws_ec2_transit_gateway" "useast1" {
  description = "Transit Gateway in us-east-1"

  auto_accept_shared_attachments = "enable"

  amazon_side_asn = 64512

  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  tags = {
    Name = "TransitGatewayUseast1"
  }
}

resource "aws_ec2_transit_gateway" "uswest2" {
  region = "us-west-2"

  description = "Transit Gateway in us-west-2"

  auto_accept_shared_attachments = "enable"

  amazon_side_asn = 64512

  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  tags = {
    Name = "TransitGatewayUsWest2"
  }
}

resource "aws_ec2_transit_gateway_peering_attachment" "this" {
  peer_account_id         = aws_ec2_transit_gateway.uswest2.owner_id
  peer_region             = "us-west-2"
  peer_transit_gateway_id = aws_ec2_transit_gateway.uswest2.id

  transit_gateway_id = aws_ec2_transit_gateway.useast1.id

  tags = {
    Name = "TGW Peering Requestor"
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "this" {
  region = "us-west-2"

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.this.id

  tags = {
    Name = "TGW Peering Accepter"
  }
}

resource "aws_route" "useast1_to_tgw" {
  route_table_id         = module.vpc1.private_route_table_ids[0]
  destination_cidr_block = module.vpc2.vpc_cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.useast1.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.vpc1]
}

resource "aws_route" "uswest2_to_tgw" {
  region = "us-west-2"

  route_table_id         = module.vpc2.private_route_table_ids[0]
  destination_cidr_block = module.vpc1.vpc_cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.uswest2.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.vpc2]
}


# ------------------------------------------------------------------
# Transit Gateway VPC attachments
# ------------------------------------------------------------------
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc1" {
  transit_gateway_id = aws_ec2_transit_gateway.useast1.id
  vpc_id             = module.vpc1.vpc_id
  subnet_ids         = module.vpc1.intra_subnets

  tags = {
    Name = "${local.name1}-tgw-attachment"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc2" {
  region = "us-west-2"

  transit_gateway_id = aws_ec2_transit_gateway.uswest2.id
  vpc_id             = module.vpc2.vpc_id
  subnet_ids         = module.vpc2.intra_subnets

  tags = {
    Name = "${local.name2}-tgw-attachment"
  }
}

# ------------------------------------------------------------------
# Transit Gateway route tables (one per region)
# Used by the VPCs
# ------------------------------------------------------------------
resource "aws_ec2_transit_gateway_route_table" "useast1_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.useast1.id

  tags = {
    Name = "useast1-rt"
  }
}

resource "aws_ec2_transit_gateway_route_table" "uswest2_rt" {
  region = "us-west-2"

  transit_gateway_id = aws_ec2_transit_gateway.uswest2.id

  tags = {
    Name = "uswest2-rt"
  }
}

# ------------------------------------------------------------------
# Associations between route tables and VPC attachments
# ------------------------------------------------------------------
resource "aws_ec2_transit_gateway_route_table_association" "useast1_vpc1" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.useast1_rt.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc1.id

  depends_on = [
    aws_ec2_transit_gateway_peering_attachment.this,
    aws_ec2_transit_gateway_peering_attachment_accepter.this
  ]
}

resource "aws_ec2_transit_gateway_route_table_association" "uswest2_vpc2" {
  region = "us-west-2"

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.uswest2_rt.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc2.id

  depends_on = [
    aws_ec2_transit_gateway_peering_attachment.this,
    aws_ec2_transit_gateway_peering_attachment_accepter.this
  ]
}

# ------------------------------------------------------------------
# Static routes for VPC -> VPC communication over peering
# ------------------------------------------------------------------
resource "aws_ec2_transit_gateway_route" "to_uswest2" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.useast1_rt.id
  destination_cidr_block         = local.vpc2_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.this.id

  depends_on = [
    aws_ec2_transit_gateway_peering_attachment.this,
    aws_ec2_transit_gateway_peering_attachment_accepter.this
  ]
}

resource "aws_ec2_transit_gateway_route" "to_useast1" {
  region = "us-west-2"

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.uswest2_rt.id
  destination_cidr_block         = local.vpc1_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this.id

  depends_on = [
    aws_ec2_transit_gateway_peering_attachment.this,
    aws_ec2_transit_gateway_peering_attachment_accepter.this
  ]
}

# ------------------------------------------------------------------
# Transit Gateway route tables for peering connectivity
# ------------------------------------------------------------------
resource "aws_ec2_transit_gateway_route_table" "useast1_uswest2_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.useast1.id

  tags = {
    Name = "useast1-uswest2-rt-peering"
  }
}

resource "aws_ec2_transit_gateway_route_table" "uswest2_useast1_rt" {
  region = "us-west-2"

  transit_gateway_id = aws_ec2_transit_gateway.uswest2.id

  tags = {
    Name = "uswest2-useast1-rt-peering"
  }
}

# ------------------------------------------------------------------
# Associations between route tables and peering attachments
# ------------------------------------------------------------------
resource "aws_ec2_transit_gateway_route_table_association" "useast1_peering" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.useast1_uswest2_rt.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.this.id

  depends_on = [
    aws_ec2_transit_gateway_peering_attachment.this,
    aws_ec2_transit_gateway_peering_attachment_accepter.this
  ]
}

resource "aws_ec2_transit_gateway_route_table_association" "uswest2_peering" {
  region = "us-west-2"

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.uswest2_useast1_rt.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this.id

  depends_on = [
    aws_ec2_transit_gateway_peering_attachment.this,
    aws_ec2_transit_gateway_peering_attachment_accepter.this
  ]
}

# ------------------------------------------------------------------
# Routes in peering route tables
# ------------------------------------------------------------------
resource "aws_ec2_transit_gateway_route" "useast1_peering_to_vpc1" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.useast1_uswest2_rt.id
  destination_cidr_block         = local.vpc1_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc1.id
}

resource "aws_ec2_transit_gateway_route" "uswest2_peering_to_vpc2" {
  region = "us-west-2"

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.uswest2_useast1_rt.id
  destination_cidr_block         = local.vpc2_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc2.id
}
