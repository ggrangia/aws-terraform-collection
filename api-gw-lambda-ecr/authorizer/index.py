from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.typing import LambdaContext
from random import random

logger = Logger()


def generate_policy(effect, resources):
    # Generate an IAM policy based on the effect (Allow/Deny) and the resource
    policy = {
        "principalId": "user",
        "policyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": "execute-api:Invoke",
                    "Effect": effect,
                    "Resource": resources,
                }
            ],
        },
    }

    return policy


@logger.inject_lambda_context
def handler(event, context):
    """
    Authorize 50% of the calls
    """
    
    # I do not suggest to log the whole event because it may log confidential parameters (passwords, api keys)
    logger.info(f"Event received: {event}")
    
    called_method_arn = [event["methodArn"]]

    effect = "Allow" if random() <= 0.5 else "Reject"

    policy = generate_policy(effect=effect, resources=called_method_arn)
    
    logger.info(f"Generated policy: {policy}")
    return policy