resource "aws_vpc_ipam" "example" {
  provider = aws.ipam

  description = "test"
  dynamic "operating_regions" {
    for_each = var.ipam_regions
    content {
      region_name = operating_regions.value
    }
  }
  cascade = true
}


// Main pool
resource "aws_vpc_ipam_pool" "main" {
  provider = aws.ipam

  address_family = "ipv4"
  ipam_scope_id  = aws_vpc_ipam.example.private_default_scope_id
  description    = "Main pool"
}

resource "aws_vpc_ipam_pool_cidr" "main" {
  provider = aws.ipam

  ipam_pool_id = aws_vpc_ipam_pool.main.id
  cidr         = var.cidr_pool
}

// Child pool (private subnets)
resource "aws_vpc_ipam_pool" "child_pvt" {
  provider = aws.ipam

  address_family      = "ipv4"
  ipam_scope_id       = aws_vpc_ipam.example.private_default_scope_id
  locale              = "eu-west-1" # region
  source_ipam_pool_id = aws_vpc_ipam_pool.main.id
  description         = "Child pvt - eu-west-1"
  auto_import         = true
}

resource "aws_vpc_ipam_pool_cidr" "child_pvt" {
  provider = aws.ipam

  ipam_pool_id = aws_vpc_ipam_pool.child_pvt.id
  cidr         = cidrsubnet(var.cidr_pool, 2, 0)
}

// Child pool ( public subnets)
resource "aws_vpc_ipam_pool" "child_pub" {
  provider = aws.ipam

  address_family      = "ipv4"
  ipam_scope_id       = aws_vpc_ipam.example.private_default_scope_id
  locale              = "eu-west-1" # region
  source_ipam_pool_id = aws_vpc_ipam_pool.main.id
  description         = "Child pub - eu-west-1"
  auto_import         = true
}

resource "aws_vpc_ipam_pool_cidr" "child_pub" {
  provider = aws.ipam

  ipam_pool_id = aws_vpc_ipam_pool.child_pub.id
  cidr         = cidrsubnet(var.cidr_pool, 2, 1)
}
