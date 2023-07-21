from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.typing import LambdaContext

logger = Logger()


@logger.inject_lambda_context
def lambda_handler(event, context: LambdaContext):
    logger.info(f"My Lambda is processing: {event}")
    # Assume the cross-account role

    # DO WORK

    # Save Work
    return {
        "Payload": 200,
    }
