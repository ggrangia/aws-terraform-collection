import boto3
from urllib.request import urlopen
import json
import os
from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.typing import LambdaContext

logger = Logger()
ALB_DNS_NAME = os.getenv("ALB_DNS_NAME", "")
PORT = os.getenv("TEST_LISTENER_PORT", "")


@logger.inject_lambda_context
def lambda_handler(event, context):
    try:
        logger.info({"event": event})
        codedeploy = boto3.client("codedeploy")
        test_status = None
        execution_status = "Failed"

        with urlopen(f"http://{ALB_DNS_NAME}:{PORT}") as response:
            test_status = response.getcode()
            content = response.read()

        text = content.decode("utf-8", "ignore")

        logger.info({"status": test_status, "Response8080": json.loads(text)})

        if test_status == 200:
            execution_status = "Succeeded"

    except Exception as error:
        logger.error(error)

    codedeploy.put_lifecycle_event_hook_execution_status(
        deploymentId=event["DeploymentId"],
        lifecycleEventHookExecutionId=event["LifecycleEventHookExecutionId"],
        status=execution_status,
    )

    return True
