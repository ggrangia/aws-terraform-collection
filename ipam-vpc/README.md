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
