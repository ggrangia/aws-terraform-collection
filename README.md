# terraform-collection

A collection of useful terraform tiny projects for your Organization

## List of snippets

- **Centralized Internet Egress**: based on this(https://d1.awsstatic.com/architecture-diagrams/ArchitectureDiagrams/NAT-gateway-centralized-egress-ra.pdf?did=wp_card&trk=wp_card) solution on AWS Architecture Center
- **Multi-account DNS resolution**: [Simplify DNS management in a multi-account environment with Route 53 Resolver](https://aws.amazon.com/blogs/security/simplify-dns-management-in-a-multiaccount-environment-with-route-53-resolver/)
- **ipam-vpc**: deploys a VPC (with public and private subnets) using AWS IPAM to manage CIDRs
- **tgw-shared_services**: Selectively route traffic across your Organizations via Transit Gateway (Route Table Associations and attachments Propagations)
- **Map Step Function**: (parallel-lambda-step-function) perform a set of operations (Lambda function) in parallel thanks to Step Function Map workflow
- **API Gateway OpenAPI**: (api-gw-lambda-ecr) creates an API Gateway with an authorizer defined using OpenAPI spec and deploys lambdas with CodeDeploy
- **R53 DNS Firewall**: (r53-dns-firewall) blocks unwanted DNS queries towards malicious domains
- **Account List**: react to Org account changes and upload a json file to S3 containing the accounts and their tags (useful to avoid aws org api throttling)
- **Local Testing with moto**: simple example to run locally moto + tftest
