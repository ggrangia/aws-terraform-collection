"""
The attachment type will drive the propagation.
(propagating an attachment defines "who" can reach it)
East-west traffic is not allowed for Standard VPCs, that is why
Standard_X are not propagated to the route table with the same name
*****************************************************************************
    Type                 |    Propagations
*****************************************************************************
Standard_NonProd         | Shared_Services_NonProd, Global
-----------------------------------------------------------------------------
Standard_Prod            | Shared_Services_Prod, Global
-----------------------------------------------------------------------------
Shared_Services_NonProd  | Standard_NonProd, Shared_Services_NonProd, Global
-----------------------------------------------------------------------------
Shared_Services_Prod     | Standard_Prod, Shared_Services_Prod, Global
-----------------------------------------------------------------------------
Global                   | All
*****************************************************************************
"""

from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.typing import LambdaContext
import json
import os
from boto3 import client

logger = Logger()

ec2_client = client("ec2")


propagation_map = {
    "Standard_NonProd": ["Global", "Shared_Services_NonProd"],
    "Standard_Prod": ["Global", "Shared_Services_Prod"],
    "Shared_Services_NonProd": [
        "Global",
        "Shared_Services_NonProd",
        "Standard_NonProd",
    ],
    "Shared_Services_Prod": ["Global", "Shared_Services_Prod", "Standard_Prod"],
    "Global": [
        "Global",
        "Shared_Services_Prod",
        "Standard_Prod",
        "Shared_Services_NonProd",
        "Standard_NonProd",
    ],
}


def getTagValue(tagsList, tagKey):
    return next((x["Value"] for x in tagsList if x["Key"] == tagKey), False)


def propagate_attachment(client, attachId, propagation_list):
    for rtNames in propagation_list:
        rtId = os.environ[rtNames]
        client.enable_transit_gateway_route_table_propagation(
            TransitGatewayRouteTableId=rtId, TransitGatewayAttachmentId=attachId
        )
        logger.info(f"Propagated {attachId} to {rtNames} ({rtId})")


def associate_attachment(client, rtId, attachId):
    response = client.associate_transit_gateway_route_table(
        TransitGatewayRouteTableId=rtId,
        TransitGatewayAttachmentId=attachId,
    )
    logger.info(f"Associated {rtId} with {attachId}")
    return response


@logger.inject_lambda_context
def lambda_handler(event: dict, context: LambdaContext):
    logger.info(event)

    msg = json.loads(event["Records"][0]["Sns"]["Message"])
    tgwAttachArn = msg["detail"]["transitGatewayAttachmentArn"]
    tgwAttachId = tgwAttachArn.split("/")[-1]
    tgwAttachResp = ec2_client.describe_transit_gateway_attachments(
        TransitGatewayAttachmentIds=[
            tgwAttachId,
        ]
    )
    if len(tgwAttachResp["TransitGatewayAttachments"]) != 1:
        logger.error(f"Expecting exactly 1 Transit Gateway Attachment: {tgwAttachResp}")
        raise ValueError(
            f"Expecting exactly 1 Transit Gateway Attachment: {tgwAttachResp}"
        )

    tgwAttachObj = tgwAttachResp["TransitGatewayAttachments"][0]

    if tgwAttachObj["State"] != "available" or tgwAttachObj["ResourceType"] != "vpc":
        logger.error(f"Attachment is in invalid state: {tgwAttachObj}")

    attachType = getTagValue(tgwAttachObj["Tags"], "Type")

    if not attachType:
        logger.error(f"Cannot find attachment Type: {tgwAttachObj}")
        raise NameError(f"Cannot find attachment Type: {tgwAttachObj}")

    logger.info(f"Found Attachment Type: {attachType}")

    # TRT association and propagation based on the extracted tag (Type)
    propagate_attachment(ec2_client, tgwAttachId, propagation_map[attachType])

    # associate the attachment with the RT specified in Type tag
    associate_attachment(ec2_client, os.environ[attachType], tgwAttachId)

    logger.info("Assocation and Propagation completed")

    return True
