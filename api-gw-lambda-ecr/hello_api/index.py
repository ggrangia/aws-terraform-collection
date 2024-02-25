from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.typing import LambdaContext

logger = Logger()


@logger.inject_lambda_context
def handler(event, context):
    logger.info(f"Event received: {event}")
    return {
        "body": "ok",
        "statusCode": 200
    }