"""
Script that reacts to an eventbridge event when a new tag of the type v* is pushed.
It assumes a 'prd' alias and a deployment configuration are already existing on the lambda function using this repository.
Moreover, the repository shoud have the same names as the lambda function.
1 - Publish lamdba version (get last lambda version)
2 - Get alias current version
3 - Create an alias for the image-tag
3 - Prepare the appspec file
4 - Start the deployment
5 - Wait for the deployment to finish
"""

from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.typing import LambdaContext
import json
import os
from boto3 import client
import time

logger = Logger()

lambda_client = client("lambda")
cd_client = client("codedeploy")


@logger.inject_lambda_context
def lambda_handler(event, context):

    logger.info(f"Event: {event}")

    repo_name = event["detail"][
        "repository-name"
    ]  # It should have the same the lambda function
    image_tag = event["detail"]["image-tag"]
    # 0- Check lambda is not updating
    lambda_update_status = lambda_client.get_function(FunctionName=repo_name)[
        "Configuration"
    ]["LastUpdateStatus"]

    while lambda_update_status == "InProgress":
        logger.info(f"Lambda {repo_name} {lambda_update_status}")
        time.sleep(2)
        lambda_update_status = lambda_client.get_function(FunctionName=repo_name)[
            "Configuration"
        ]["LastUpdateStatus"]

    if lambda_update_status != "Successful":
        err_str = f"Last update {lambda_update_status}"
        logger.error(err_str)
        raise ValueError(err_str)

    # 1 - Publish lambda version
    # Create a new version. If the version exists already, it return its description
    version_response = lambda_client.publish_version(
        Description=image_tag,
        FunctionName=repo_name,
    )
    logger.info(f"Version response: {version_response}")

    target_version = version_response["Version"]

    # 2 - Get current prd alias
    prd_alias_resp = lambda_client.get_alias(FunctionName=repo_name, Name="prd")
    prd_current_version = prd_alias_resp["FunctionVersion"]

    alias_tag_name = image_tag.replace(".", "-")  # . are not allowed

    # 3 - Create tag alias
    create_reponse = lambda_client.create_alias(
        FunctionName=repo_name,
        Name=alias_tag_name,
        FunctionVersion=target_version,
        Description=image_tag,
    )

    logger.info(f"Alias response: {create_reponse}")

    # Start "prd" deployment
    # Also application name and deployment group have the same name as the repo

    appspec_content = {
        "content": {
            "version": 0.0,
            "Resources": [
                {
                    "myLambdaFunction": {
                        "Type": "AWS::Lambda::Function",
                        "Properties": {
                            "Name": repo_name,
                            "Alias": "prd",
                            "CurrentVersion": prd_current_version,
                            "TargetVersion": target_version,
                        },
                    }
                }
            ],
        }
    }

    deployment_resp = cd_client.create_deployment(
        applicationName=repo_name,
        deploymentGroupName=repo_name,
        deploymentConfigName="CodeDeployDefault.LambdaAllAtOnce",
        description=f"Updating {repo_name} to f{image_tag}",
        revision={
            "revisionType": "AppSpecContent",
            "appSpecContent": {"content": json.dumps(appspec_content)},
        },
    )

    deployment_id = deployment_resp["deploymentId"]

    status = cd_client.get_deployment(deploymentId=deployment_id)["status"]

    transient_status = ["Created", "InProgress", "Pending", "Queued", "Ready"]

    while status in transient_status:
        logger.info(f"Status ... {status}")

        time.sleep(5)
        status = cd_client.get_deployment(deploymentId=deployment_id)["status"]

    if status != "Succeeded":
        err_str = f"Deployment {deployment_id} ended {status}"
        logger.error(err_str)
        raise ValueError(err_str)

    return True
