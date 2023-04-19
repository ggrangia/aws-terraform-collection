from index import ec2_client
from moto.core import patch_client
from moto import mock_ec2

patch_client(ec2_client)
import pytest
import os


@pytest.fixture(scope="function")
def setup_tgw():
    with mock_ec2():
        tgwObj = ec2_client.create_transit_gateway(
        Description='testTGW',
        Options={
            'AmazonSideAsn': 123,
            'AutoAcceptSharedAttachments': 'disable',
            'DefaultRouteTableAssociation': 'disable',
            'DefaultRouteTablePropagation': 'disable',
        })

        rtNames = os.environ["TGW_RT_NAMES_LIST"].split(",")
        print(rtNames)
        tgwId = tgwObj["TransitGateway"]["TransitGatewayId"]
        for name  in rtNames:
            r = ec2_client.create_transit_gateway_route_table(
                TransitGatewayId=tgwId,
                TagSpecifications=[
                    {
                        'ResourceType': 'transit-gateway-route-table',
                        'Tags': [
                            {
                                'Key': 'Name',
                                'Value': name
                            },
                        ]
                    },
                ],
            )
            os.environ[name] = r["TransitGatewayRouteTable"]["TransitGatewayRouteTableId"]

        yield {
            "transit_gateway_id": tgwId,
            "client": ec2_client,
            "routeTableNames": rtNames
        }
