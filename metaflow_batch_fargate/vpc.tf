module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.7"

  name = "eoliann-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  # One NAT Gateway 
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_vpn_gateway = false
}

module "vpc_v6" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.7"

  name = "eoliann-vpc-v6"

  azs         = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  enable_ipv6 = true

  public_subnet_ipv6_native    = true
  public_subnet_ipv6_prefixes  = [0, 1, 2]
  private_subnet_ipv6_native   = true
  private_subnet_ipv6_prefixes = [3, 4, 5]

  # RDS currently only supports dual-stack so IPv4 CIDRs will need to be provided for subnets
  # database_subnet_ipv6_native   = true
  # database_subnet_ipv6_prefixes = [6, 7, 8]
  enable_nat_gateway = false

  create_egress_only_igw = true

}


resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = true
  tags = {
    Name = "main"
  }
}


resource "aws_subnet" "subv6" {

  vpc_id = aws_vpc.main.id

  ipv6_cidr_block                                = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 1)
  assign_ipv6_address_on_creation                = true # necessary for ipv6 native subnet
  ipv6_native                                    = true
  enable_resource_name_dns_aaaa_record_on_launch = true
}
