This project is a simple example of how to deploy (and share it with your Organization) an IPAM and use it to create your VPC (and subnets).

It is not meant to be a fully-fledged solution, but instead, it gives you a quick snippet that can be used as a base for your IaC via Terraform.

## Deployed Resources

The following resources will be deployed:
* 1 IPAM
* 1 Main Pool
* 1 Child Private Pool
* 1 Child Public Pool
* 1 VPC
* 3 Private Subnets
* 3 Public Subnets
* 1 NAT
* 1 Internet Gateway
* 2 Custom Route Tables

## Description
As mentioned before, some enhancement should be done before using this code directly in your IAC.
* IPAM and VPCs should live in separate projects/state files, especially if you are using Organizations. Here, for simplicity, I used two providers to overcome this problem.
* You might encounter problems having your IPAM correctly scan all the accounts in your ORG. I suggest following [this](https://docs.aws.amazon.com/vpc/latest/ipam/enable-integ-ipam.html) guide and creating a delegated administrator for the service *ipam.amazonaws.com*. Be careful: you cannot register a master account as a delegated administrator for your organization.

I chose to explicitly assign 4 different CIDRs to my VPC. I did it because I wanted to deploy across all the az and I did not want to waste any private IP space (the VPC CIDRs are the subnets CIDRs). Instead, I chose a different approach for the public subnets. In this specific example, I assigned the VPC a /26 CIDR but the 3 subnets were /28, effectively wasting one /28 (if instead of 3 /28 you use 2 /27, there is no IP space wasted.)

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_aws.ipam"></a> [aws.ipam](#provider\_aws.ipam) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eip.nat_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.pub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.pvt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.test](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_ipam.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipam) | resource |
| [aws_vpc_ipam_pool.child_pub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipam_pool) | resource |
| [aws_vpc_ipam_pool.child_pvt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipam_pool) | resource |
| [aws_vpc_ipam_pool.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipam_pool) | resource |
| [aws_vpc_ipam_pool_cidr.child_pub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipam_pool_cidr) | resource |
| [aws_vpc_ipam_pool_cidr.child_pvt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipam_pool_cidr) | resource |
| [aws_vpc_ipam_pool_cidr.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipam_pool_cidr) | resource |
| [aws_vpc_ipv4_cidr_block_association.public_cidr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipv4_cidr_block_association) | resource |
| [aws_vpc_ipv4_cidr_block_association.secondary_cidr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipv4_cidr_block_association) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidr_pool"></a> [cidr\_pool](#input\_cidr\_pool) | n/a | `string` | `"10.64.0.0/10"` | no |
| <a name="input_ipam_regions"></a> [ipam\_regions](#input\_ipam\_regions) | n/a | `list(string)` | <pre>[<br/>  "eu-west-1"<br/>]</pre> | no |
| <a name="input_secondary_private_cidr"></a> [secondary\_private\_cidr](#input\_secondary\_private\_cidr) | n/a | `number` | `2` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | n/a | `number` | `3` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc"></a> [vpc](#output\_vpc) | n/a |
<!-- END_TF_DOCS -->
