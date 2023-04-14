from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.typing import LambdaContext
import json
from boto3 import client

logger = Logger()

# TODO:: Add tests

ec2_client = client("ec2")
sts_client = client("sts")


# FIXME: Pass correct role. From env??? Role to be created (in every account)
def getTargetAccountClient(accountId, sts, sessionName="TGW-RT-PROP"):
    targetAccCred = sts.assume_role(RoleArn="", RoleSessionName=sessionName)
    return client(
        "ec2",
        aws_access_key_id=targetAccCred["Credentials"]["AccessKeyId"],
        aws_secret_access_key=targetAccCred["Credentials"]["SecretAccessKey"],
        aws_session_token=targetAccCred["Credentials"]["SessionToken"],
    )


def describeVpc(vpcId, ec2):
    return ec2.describe_vpcs(
        VpcIds=[
            vpcId,
        ]
    )[
        "Vpcs"
    ][0]


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
        logger.error(f"Too many attachments found: {tgwAttachResp}")
        return False

    tgwAttachObj = tgwAttachResp["TransitGatewayAttachments"][0]

    if tgwAttachObj["State"] != "available" or tgwAttachObj["ResourceType"] != "vpc":
        logger.error(f"Attachment is in invalid state: {tgwAttachObj}")

    attachName = next(
        (x["Value"] for x in tgwAttachObj["Tags"] if x["Key"] == "Name"), False
    )
    if not attachName:
        logger.error(f"Cannot find attachment name: {tgwAttachObj}")

    vpcId = tgwAttachObj["ResourceId"]
    vpcOwner = tgwAttachObj["ResourceOwnerId"]

    vpcObj = describeVpc(vpcId, getTargetAccountClient(vpcOwner, sts_client))

    # TODO: Extract RT info from attachment tags
    # TODO: Do RT association and propagation based on the extracted tag

    return True
