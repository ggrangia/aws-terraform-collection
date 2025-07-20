This project implements [Architecture for Centralized Internet Egress with NAT Gateway – Inter-VPC Communication Disabled](https://aws.amazon.com/architecture/?cards-all.sort-by=item.additionalFields.sortDate&cards-all.sort-order=desc&awsf.content-type=*all&awsf.methodology=*all&awsf.tech-category=*all&awsf.industries=*all&cards-all.q=egress&cards-all.q_operator=AND&awsm.page-cards-all=1) taken from AWS Architecture Center.

## Description

The project is made of three modules:
* Spoke VPC - all your workload VPCs
* Egress VPC - central VPC that
* Transit Gateway

All the traffic towards the internet is routed from any Spoke VPC towards the Egress VPC passing through the Transit Gateway. No traffic is allowed between Spoke VPCs. This is achieved through the Transit Gateway Route Tables:
* Spoke RT is associated with any Spoke VPC and has a rule that forwards all the non-local traffic (0.0.0.0/0) towards the Egress VPC Attachment
* Egress RT is associated only with the Egress VPC. It has a route back towards all the spoke VPCs CIDR. In this example, there is only one Spoke VPC and it is done thanks to a route Propagation, but it can be used with a wider CIDR if the network planning has been done accordingly (e.g 10.0.0.0/8 is the CIDR of all my private VPCs).

One thing to remember is to set up the routes in the subnet routes tables, both for the traffic going towards the internet and the traffic going back to the VPC.


The path towards Internet:
* Spoke Subnet VPC (0.0.0.0/0) -> Transit Gateway
* Spoke TGW Route Table  (0.0.0.0/0) ->  Egress VPC TGW Attachment
* Egress Private Subnet (0.0.0.0/0) -> NAT
* Egress Public Subnet (0.0.0.0/0) -> Internet Gateway

The path back to the VPC:
* Egress Public Subnet (10.0.0.0/8) -> Transit Gateway
* Egress TGW Route Table (10.0.0.0/8) -> Spoke VPC Attachment (Propagation)
* Spoke Subnet VPC (local)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.4.0 |
| <a name="provider_aws.tgw"></a> [aws.tgw](#provider\_aws.tgw) | 6.4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_egress"></a> [egress](#module\_egress) | ./egress_vpc | n/a |
| <a name="module_spoke"></a> [spoke](#module\_spoke) | ./spoke_vpc | n/a |
| <a name="module_tgw"></a> [tgw](#module\_tgw) | ./tgw | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ec2_transit_gateway_route.pvt_blackhole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.spoke_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route_table_association.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_association.spoke](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_propagation.vpc_tgw_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_propagation) | resource |
| [aws_ec2_transit_gateway_vpc_attachment_accepter.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_vpc_attachment_accepter) | resource |
| [aws_ec2_transit_gateway_vpc_attachment_accepter.spoke](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_vpc_attachment_accepter) | resource |
| [aws_ram_principal_association.tgw_org](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_principal_association) | resource |
| [aws_ram_resource_association.tgw_org](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) | resource |
| [aws_ram_resource_share.tgw_org](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_share) | resource |
| [aws_route.default_route_pvt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.egress_backroute_pub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.egress_backroute_pvt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_organizations_organization.mine](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_egress_main_cidr"></a> [egress\_main\_cidr](#input\_egress\_main\_cidr) | n/a | `string` | `"10.80.1.64/26"` | no |
| <a name="input_egress_public_cidr"></a> [egress\_public\_cidr](#input\_egress\_public\_cidr) | n/a | `string` | `"10.80.1.128/26"` | no |
| <a name="input_spoke_main_cidr"></a> [spoke\_main\_cidr](#input\_spoke\_main\_cidr) | n/a | `string` | `"10.80.0.0/24"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
