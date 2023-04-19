from index import getTagValue, lambda_handler, associateAttachment, propagateAttachment
from index import propagation_map
import os

class TestTgwPropagation:
    def setup_vpc_and_attachment(self, client, vpcInfo):
        vpc = client.create_vpc(
            CidrBlock=vpcInfo["Cidr"],
            TagSpecifications=[
                {
                    'ResourceType': 'vpc',
                    'Tags': [
                        {
                            'Key': 'Name',
                            'Value': vpcInfo["Name"]
                        },
                    ]
                },
            ])
        vpcId = vpc["Vpc"]["VpcId"]
        # Create subnets
        subnet = client.create_subnet(
            TagSpecifications=[
                {
                    'ResourceType': 'subnet',
                    'Tags': [
                        {
                            'Key': 'Name',
                            'Value': 'subnet'
                        },
                    ]
                },
            ],
            AvailabilityZone='eu-west-1a',
            CidrBlock=vpcInfo["Cidr"],
            VpcId=vpcId
        )
        subnetId = subnet["Subnet"]["SubnetId"]
        # Create tgw_vpc_attachment
        attachment = client.create_transit_gateway_vpc_attachment(
            TransitGatewayId=vpcInfo["TgwId"],
            VpcId=vpcId,
            SubnetIds=[
                subnetId,
            ],
            Options={
                'DnsSupport': 'enable',
                'Ipv6Support': 'enable',
                'ApplianceModeSupport': 'disable'
            },
            TagSpecifications=[
                {
                    'ResourceType': 'transit-gateway-attachment',
                    'Tags': [
                        {
                            'Key': 'Type',
                            'Value': vpcInfo["AttachmentType"]
                        },
                    ]
                },
            ],
        )
        attachmentId = attachment["TransitGatewayVpcAttachment"]["TransitGatewayAttachmentId"]
        return attachmentId


    def test_lambda_handler(self):
        assert False

    def test_getTagValue(self):
        tags = [
            {"Key": "test1", "Value": "test"},
            {"Key": "Type", "Value": "attachment_type"},
            {"Key": "Name", "Value": "Global"},
        ]
        name = getTagValue(tags, "Name")
        typeTag = getTagValue(tags, "Type")

        assert name == "Global"
        assert typeTag == "attachment_type"

    def test_propagateAttachmentGlobal(self, setup_tgw):
        client = setup_tgw["client"]
        attachType = "Global"
        vpcInfo = {
            "Name": "VpcGlobal",
            "TgwId": setup_tgw["transit_gateway_id"],
            "Cidr": "10.10.0.0/24",
            "AttachmentType": attachType
        }
        attachmentId = self.setup_vpc_and_attachment(client, vpcInfo)
        # TODO: Find suitable test condition
        propagateAttachment(client, attachmentId, propagation_map[attachType])
        # Check the propagated RT is in the propagation list
        prop_count = 0
        for name in setup_tgw["routeTableNames"]:
            rtId = os.environ[name]
            response = client.get_transit_gateway_route_table_propagations(
                TransitGatewayRouteTableId=rtId,
                 Filters=[
                    {
                        'Name': 'transit-gateway-attachment-id',
                        'Values': [
                            attachmentId,
                        ]
                    },
                ])
            print(response['TransitGatewayRouteTablePropagations'])
            if len(response['TransitGatewayRouteTablePropagations']) and response['TransitGatewayRouteTablePropagations'][0].get('TransitGatewayAttachmentId'):
                # look for the name in the propagation list
                prop_count += 1
                assert name in propagation_map[attachType]

        assert prop_count == len(propagation_map[attachType])

    def test_associateAttachment(self):
        assert False
