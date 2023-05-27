This project shows a setup with multiple Transit Gateway Route Tables to route traffic across your Organization.

## Description
This project is organized as follows:
* 1 Transit Gateway
* Multiple VPCs in "service" accounts that will be propagated to TGW route tables based on tags
* 1 Lambda Function (in eu-west-1) that performs TGW RT associations and propagations
* Network Manger + eventbridge rule (in Oregon)
* SNS (in Oregon) that recieves network manager events and forward it to the Lambda func

The communication across the different VPCs is guided by the Transit Gateway route tables and propagations.
In this example, we have different types of VPC:
- Standard -> No communications allowed between Standard VPCs
- Shared_Services -> Reachable by all the VPCs from the same environment
- Global -> Reachable by any VPC in your Org (even across different environments)

To put it simply, propagating an attachment to a Transint Gateway route table means making it reachable
from all the attachment associated with that route table.

| Type | Progagations |
| --- | --- |
| Standard_NonProd | Shared_Services_NonProd, Global |
| Standard_Prod | Shared_Services_Prod, Global |
| Shared_Services_NonProd | Standard_NonProd, Shared_Services_NonProd, Global |
| Shared_Services_Prod | Standard_Prod, Shared_Services_Prod, Global |
| Global | All |

As a reminder, in production environments I strongly suggest to separate the transit gateway and the VPCs codes.
With this project, you will incur into error when you are destroying everything because terraform tries to destroy
Transit Gateway Route Table where the propagations and associations have been done via lambda functions.
Keeping the code separated (into different statefiles), you will easily delete VPCs and automatically delete the propagation.
It is unusual to destroy and re-create transit gateway and route tables very often.