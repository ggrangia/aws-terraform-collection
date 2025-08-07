from random import random

from aws_lambda_powertools import Logger

logger = Logger()


def generate_policy(probability, resources):
    """
    Generate an IAM Allow policy based on the resource.
    If resources is empty, the request is not authorized.
    """
    policy = {
        "principalId": "user",
        "policyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": "execute-api:Invoke",
                    "Effect": "Allow",
                    "Resource": resources,
                }
            ],
        },
        "context": {"probability": str(probability)},
    }

    return policy


@logger.inject_lambda_context
def handler(event, context):
    """
    Authorize 50% of the calls
    """

    # I do not suggest to log the whole event because it may log confidential parameters (passwords, api keys)
    logger.info(f"Event received: {event}")

    prob = random()

    called_method_arn = [event["methodArn"]] if prob <= 0.5 else []

    policy = generate_policy(probability=prob, resources=called_method_arn)

    logger.info(f"Generated policy: {policy}")
    return policy
