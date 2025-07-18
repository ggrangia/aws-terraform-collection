This project implements [Simplify DNS management in a multi-account environment with Route 53 Resolver](https://aws.amazon.com/blogs/security/simplify-dns-management-in-a-multiaccount-environment-with-route-53-resolver/)

## Description

The project solves the problem of DNS resolution in a multi-account evironment, specifically the third case described in the link above. For on-prem resolution, just forward the dns queries directed towards your cloud domain to the Inbound endpoints IPs.

The following resources will be deployed:
* 3 VPCs from the famous [module](https://github.com/terraform-aws-modules/terraform-aws-vpc)
* 3 R53 Inbound Endpoints
* 3 R53 Outbound Endpoints
* R53 resolver rules form both the cloud domain and custom destinations
* test.account1.mydomain.mycloud and test.account2.mydomain.mycloud
* RAM Share for the resolver rules
* 2 Private hosted zones with a test record

One central VPC will host both out Outbound and Inbound Endpoints.
Inbound endpoints can be thought like "proxies" for the .2 resolvers.
By RAM Sharing the resolver rules, you also "share" the Outbound endpoints. That's why the DNS resolution from the test accounts work without any path
connectivity betweeen the accounts, by simply associating the private hosted zones with the "central" VPC. The DNS query is actually resolved in that VPC, not in the test accounts VPCs.
To test the DNS resolution, create an EC2 instance in a test account and perform a nslookup for the record in the other accounts.

## Notes

IMPORTANT: I am deploying 6 resolver endpoints (3 Inbound and 3 outboud). They are expensive. For testing, one for each type is enough. For most production environments, 2 of each will suffice.

I could have used a module for the two "support" accounts, but I skipped it for simplicity.

Here I have everything defined in the same statefile, so I can access the resolver rules in the "support" accounts. In a real scenario, it is likely that they do not all live in the same statefile, hence a data lookup is be necessary.

There is no need to associate the cloud domain resover rule with the VPC where the Endpoints are hosted. If you try, it will fail.

IN the endpoints definition, the dynamic field might sometimes fail to show the plan correctly (it tells you it is going to change the IPs). If that happens, I suggest using a "known in advance" key (i.e. the azs in your region).

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.35.0 |
| <a name="provider_aws.account1"></a> [aws.account1](#provider\_aws.account1) | 5.35.0 |
| <a name="provider_aws.account2"></a> [aws.account2](#provider\_aws.account2) | 5.35.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_account1_vpc"></a> [account1\_vpc](#module\_account1\_vpc) | terraform-aws-modules/vpc/aws | n/a |
| <a name="module_account2_vpc"></a> [account2\_vpc](#module\_account2\_vpc) | terraform-aws-modules/vpc/aws | n/a |
| <a name="module_main_vpc"></a> [main\_vpc](#module\_main\_vpc) | terraform-aws-modules/vpc/aws | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ram_principal_association.rules_org](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_principal_association) | resource |
| [aws_ram_resource_association.extra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) | resource |
| [aws_ram_resource_association.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) | resource |
| [aws_ram_resource_share.rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_share) | resource |
| [aws_route53_record.test1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.test2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_resolver_endpoint.inbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_endpoint) | resource |
| [aws_route53_resolver_endpoint.outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_endpoint) | resource |
| [aws_route53_resolver_rule.extra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_rule) | resource |
| [aws_route53_resolver_rule.mydomain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_rule) | resource |
| [aws_route53_resolver_rule_association.extra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_rule_association) | resource |
| [aws_route53_resolver_rule_association.extra_account1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_rule_association) | resource |
| [aws_route53_resolver_rule_association.extra_account2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_rule_association) | resource |
| [aws_route53_resolver_rule_association.main_account1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_rule_association) | resource |
| [aws_route53_resolver_rule_association.main_account2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_rule_association) | resource |
| [aws_route53_vpc_association_authorization.account1_main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_vpc_association_authorization) | resource |
| [aws_route53_vpc_association_authorization.account2_main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_vpc_association_authorization) | resource |
| [aws_route53_zone.account1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route53_zone.account2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route53_zone_association.account1_main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone_association) | resource |
| [aws_route53_zone_association.account2_main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone_association) | resource |
| [aws_security_group.dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.dns_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.dns_tcp_ingr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.dns_udp_ingr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_organizations_organization.myorg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_extra_fwd_rules"></a> [extra\_fwd\_rules](#input\_extra\_fwd\_rules) | n/a | `list` | <pre>[<br/>  {<br/>    "domain": "other.domain",<br/>    "ip": [<br/>      "35.53.11.110",<br/>      "35.53.12.110"<br/>    ],<br/>    "name": "other_domain"<br/>  },<br/>  {<br/>    "domain": "another.domain",<br/>    "ip": [<br/>      "1.1.1.1",<br/>      "2.2.2.2"<br/>    ],<br/>    "name": "another_domain"<br/>  }<br/>]</pre> | no |
| <a name="input_private_domain"></a> [private\_domain](#input\_private\_domain) | n/a | `string` | `"mydomain.mycloud"` | no |
| <a name="input_private_network_cidr"></a> [private\_network\_cidr](#input\_private\_network\_cidr) | n/a | `string` | `"10.0.0.0/8"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
