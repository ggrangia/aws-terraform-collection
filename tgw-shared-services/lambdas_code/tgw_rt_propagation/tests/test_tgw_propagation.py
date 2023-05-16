from index import getTagValue, lambda_handler, associateAttachment, propagateAttachment
from index import propagation_map
import os, json


class ContextMock:
    def __init__(self) -> None:
        self.function_name = "lambda_handler"
        self.function_memory_size = 512
        self.function_arn = "test_arn"
        self.function_request_id = "1111111111111"
        self.memory_limit_in_mb = 512
        self.invoked_function_arn = "test:arn"
        self.aws_request_id = "test_aws_req"


class TestTgwPropagation:
    def setup_vpc_and_attachment(self, client, vpcInfo):
        vpc = client.create_vpc(
            CidrBlock=vpcInfo["Cidr"],
            TagSpecifications=[
                {
                    "ResourceType": "vpc",
                    "Tags": [
                        {"Key": "Name", "Value": vpcInfo["Name"]},
                    ],
                },
            ],
        )
        vpcId = vpc["Vpc"]["VpcId"]
        # Create subnets
        subnet = client.create_subnet(
            TagSpecifications=[
                {
                    "ResourceType": "subnet",
                    "Tags": [
                        {"Key": "Name", "Value": "subnet"},
                    ],
                },
            ],
            AvailabilityZone="eu-west-1a",
            CidrBlock=vpcInfo["Cidr"],
            VpcId=vpcId,
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
                "DnsSupport": "enable",
                "Ipv6Support": "enable",
                "ApplianceModeSupport": "disable",
            },
        )
        attachmentId = attachment["TransitGatewayVpcAttachment"][
            "TransitGatewayAttachmentId"
        ]
        # Add Tags explicitly
        client.create_tags(
            Resources=[
                attachmentId,
            ],
            Tags=[
                {
                    "Key": "Type",
                    "Value": vpcInfo["AttachmentType"],
                },
            ],
        )
        return attachmentId

    def test_lambda_handler(self, setup_tgw):
        ctx = ContextMock()
        client = setup_tgw["client"]

        vpcInfo = {
            "Name": "VpcGlobal",
            "TgwId": setup_tgw["transit_gateway_id"],
            "Cidr": "10.10.0.0/24",
            "AttachmentType": "Global",
        }
        attachmentId = self.setup_vpc_and_attachment(client, vpcInfo)
        print()
        eventMsgObj = {"detail": {"transitGatewayAttachmentArn": f"{attachmentId}"}}
        event = {"Records": [{"Sns": {"Message": json.dumps(eventMsgObj)}}]}
        resp = lambda_handler(event, ctx)
        print(f"resp: {resp}")
        # FIXME: test both propagation and association are correct
        assert resp == True

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

    def test_propagateAttachment(self, setup_tgw):
        client = setup_tgw["client"]
        testCases = [
            {
                "Name": "VpcGlobal",
                "TgwId": setup_tgw["transit_gateway_id"],
                "Cidr": "10.10.0.0/24",
                "AttachmentType": "Global",
            },
            {
                "Name": "VpcStandard_NonProd",
                "TgwId": setup_tgw["transit_gateway_id"],
                "Cidr": "10.10.1.0/24",
                "AttachmentType": "Standard_NonProd",
            },
            {
                "Name": "VpcStandard_Prod",
                "TgwId": setup_tgw["transit_gateway_id"],
                "Cidr": "10.10.2.0/24",
                "AttachmentType": "Standard_Prod",
            },
            {
                "Name": "VpcShared_Services_NonProd",
                "TgwId": setup_tgw["transit_gateway_id"],
                "Cidr": "10.10.3.0/24",
                "AttachmentType": "Shared_Services_NonProd",
            },
            {
                "Name": "VpcShared_Services_Prod",
                "TgwId": setup_tgw["transit_gateway_id"],
                "Cidr": "10.10.4.0/24",
                "AttachmentType": "Shared_Services_Prod",
            },
        ]
        for case in testCases:
            attachType = case["AttachmentType"]
            attachmentId = self.setup_vpc_and_attachment(client, case)
            propagateAttachment(client, attachmentId, propagation_map[attachType])
            # Check the propagated RT is in the propagation list
            prop_count = 0
            for name in setup_tgw["routeTableNames"]:
                rtId = os.environ[name]
                response = client.get_transit_gateway_route_table_propagations(
                    TransitGatewayRouteTableId=rtId,
                    Filters=[
                        {
                            "Name": "transit-gateway-attachment-id",
                            "Values": [
                                attachmentId,
                            ],
                        },
                    ],
                )
                # print(response['TransitGatewayRouteTablePropagations'])
                if len(response["TransitGatewayRouteTablePropagations"]) and response[
                    "TransitGatewayRouteTablePropagations"
                ][0].get("TransitGatewayAttachmentId"):
                    # look for the name in the propagation list
                    prop_count += 1
                    assert name in propagation_map[attachType]

            assert prop_count == len(propagation_map[attachType])

    def test_associateAttachment(self, setup_tgw):
        client = setup_tgw["client"]
        testCases = [
            {
                "Name": "VpcGlobal",
                "TgwId": setup_tgw["transit_gateway_id"],
                "Cidr": "10.10.0.0/24",
                "AttachmentType": "Global",
            },
            {
                "Name": "VpcStandard_NonProd",
                "TgwId": setup_tgw["transit_gateway_id"],
                "Cidr": "10.10.1.0/24",
                "AttachmentType": "Standard_NonProd",
            },
            {
                "Name": "VpcStandard_Prod",
                "TgwId": setup_tgw["transit_gateway_id"],
                "Cidr": "10.10.2.0/24",
                "AttachmentType": "Standard_Prod",
            },
            {
                "Name": "VpcShared_Services_NonProd",
                "TgwId": setup_tgw["transit_gateway_id"],
                "Cidr": "10.10.3.0/24",
                "AttachmentType": "Shared_Services_NonProd",
            },
            {
                "Name": "VpcShared_Services_Prod",
                "TgwId": setup_tgw["transit_gateway_id"],
                "Cidr": "10.10.4.0/24",
                "AttachmentType": "Shared_Services_Prod",
            },
        ]
        for case in testCases:
            attachType = case["AttachmentType"]
            attachmentId = self.setup_vpc_and_attachment(client, case)
            associateAttachment(client, os.environ[attachType], attachmentId)
            associationsCount = 0
            for name in setup_tgw["routeTableNames"]:
                rtId = os.environ[name]
                response = client.get_transit_gateway_route_table_associations(
                    TransitGatewayRouteTableId=rtId,
                    Filters=[
                        {
                            "Name": "transit-gateway-attachment-id",
                            "Values": [
                                attachmentId,
                            ],
                        },
                    ],
                )
                # print(response["Associations"])
                if len(response["Associations"]) and response["Associations"][0].get(
                    "TransitGatewayAttachmentId"
                ):
                    associationsCount += 1
                    assert name == attachType

            assert associationsCount == 1
