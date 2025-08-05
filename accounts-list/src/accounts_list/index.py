import boto3
import json
import os
from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.typing import LambdaContext

logger = Logger()


def get_all_accounts():
    """
    Retrieves all accounts in the AWS Organization.
    """
    client = boto3.client("organizations")
    accounts = []
    paginator = client.get_paginator("list_accounts")
    page_iterator = paginator.paginate()
    for page in page_iterator:
        accounts.extend(page["Accounts"])
    return accounts


def get_account_tags(account_id):
    """
    Retrieves tags for a specific AWS account.
    """
    client = boto3.client("organizations")
    try:
        response = client.list_tags_for_resource(ResourceId=account_id)
        return response["Tags"]
    except client.exceptions.AWSOrganizationsNotInUseException:
        logger.info("AWS Organizations is not in use.")
        return []
    except Exception as e:
        logger.error(f"Error getting tags for account {account_id}: {e}")
        return []


@logger.inject_lambda_context
def lambda_handler(event: dict, context: LambdaContext) -> dict:
    logger.info({"event": event})

    s3_bucket_name = os.environ.get("S3_BUCKET_NAME")
    if not s3_bucket_name:
        logger.error("S3_BUCKET_NAME environment variable not set.")
        return False

    accounts = get_all_accounts()
    accounts_with_tags = []

    for account in accounts:
        # TODO: check tags
        tags = get_account_tags(account["Id"])
        account_info = {
            "Id": account["Id"],
            "Arn": account["Arn"],
            "Email": account["Email"],
            "Name": account["Name"],
            "Status": account["Status"],
            "Tags": tags,
        }
        accounts_with_tags.append(account_info)

    s3_client = boto3.client("s3")
    file_name = "accounts.json"

    try:
        s3_client.put_object(
            Bucket=s3_bucket_name,
            Key=file_name,
            Body=json.dumps(accounts_with_tags, indent=4),
        )
        logger.info(f"Successfully uploaded {file_name} to {s3_bucket_name}")
        return True
    except Exception as e:
        logger.error(f"Error uploading file to S3: {e}")
        return False
