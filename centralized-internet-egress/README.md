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
