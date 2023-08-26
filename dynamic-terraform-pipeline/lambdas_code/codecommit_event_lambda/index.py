from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.typing import LambdaContext
import boto3
import os

logger = Logger()

client = boto3.client("codebuild")

CODEBUILD_PROJECT_NAME = os.getenv("CODEBUILD_PROJECT", "")


@logger.inject_lambda_context
def lambda_handler(event: dict, context: LambdaContext):
    logger.info(f"Event: {event}")

    codecommit_repo_name = event["resources"][0].split(":")[-1]
    branch_refs = event["detail"]["referenceFullName"]
    region = event["region"]

    logger.info(f"codecommit_repo_name: {codecommit_repo_name}")
    logger.info(f"branch_refs: {branch_refs}")
    logger.info(f"region: {region}")

    response = client.start_build(
        projectName=CODEBUILD_PROJECT_NAME,
        sourceVersion=branch_refs,
        sourceTypeOverride="CODECOMMIT",
        sourceLocationOverride=f"https://git-codecommit.{region}.amazonaws.com/v1/repos/{codecommit_repo_name}",
    )

    logger.info(f"CodeBuild response: {response}")
