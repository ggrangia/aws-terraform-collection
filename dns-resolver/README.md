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

I could have used a module for the two "support" accounts, but I skipped it for simplicity.

Here I have everything defined in the same statefile, so I can access the resolver rules in the "support" accounts. In a real scenario, it is likely that they do not all live in the same statefile, hence a data lookup is be necessary.

There is no need to associate the cloud domain resover rule with the VPC where the Endpoints are hosted. If you try, it will fail.

IN the endpoints definition, the dynamic field might sometimes fail to show the plan correctly (it tells you it is going to change the IPs). If that happens, I suggest using a "known in advance" key (i.e. the azs in your region).