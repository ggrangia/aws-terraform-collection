This project implements Architecture for Centralized Internet Egress with NAT Gateway – Inter-VPC Communication Disabled(https://aws.amazon.com/architecture/?cards-all.sort-by=item.additionalFields.sortDate&cards-all.sort-order=desc&awsf.content-type=*all&awsf.methodology=*all&awsf.tech-category=*all&awsf.industries=*all&cards-all.q=egress&cards-all.q_operator=AND&awsm.page-cards-all=1) taken from AWS Architecture Center.

## Description

The project is made by three modules:
* Spoke VPC - all your workload VPCs
* Egress VPC - central VPC that 
* Transit Gateway
