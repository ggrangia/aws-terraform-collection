import boto3
import json
import os
import pytest
from moto import mock_aws
from accounts_list.index import lambda_handler


@pytest.fixture
def aws_credentials():
    """Mocked AWS Credentials for moto."""
    os.environ["AWS_ACCESS_KEY_ID"] = "testing"
    os.environ["AWS_SECRET_ACCESS_KEY"] = "testing"
    os.environ["AWS_SECURITY_TOKEN"] = "testing"
    os.environ["AWS_SESSION_TOKEN"] = "testing"


@pytest.fixture
def s3_bucket_name():
    return "test-bucket"


@pytest.fixture
def mock_environment(s3_bucket_name):
    os.environ["S3_BUCKET_NAME"] = s3_bucket_name


@mock_aws
def test_lambda_handler(aws_credentials, mock_environment, s3_bucket_name):
    # Create a mock S3 bucket
    s3_client = boto3.client("s3", region_name="us-east-1")
    s3_client.create_bucket(Bucket=s3_bucket_name)

    # Create a mock organization and accounts
    org_client = boto3.client("organizations", region_name="us-east-1")
    org_client.create_organization(FeatureSet="ALL")

    account1 = org_client.create_account(
        Email="test1@example.com", AccountName="Test Account 1"
    )["CreateAccountStatus"]["AccountId"]
    account2 = org_client.create_account(
        Email="test2@example.com", AccountName="Test Account 2"
    )["CreateAccountStatus"]["AccountId"]

    org_client.tag_resource(ResourceId=account1, Tags=[{"Key": "Env", "Value": "Dev"}])

    # Invoke the lambda handler
    response = lambda_handler({}, None)

    assert response["statusCode"] == 200

    # Verify the file was uploaded to S3
    s3_object = s3_client.get_object(Bucket=s3_bucket_name, Key="accounts.json")
    data = json.loads(s3_object["Body"].read().decode("utf-8"))

    assert len(data) == 3  # Root account + 2 created accounts

    # Find our test accounts in the data
    test_account_1_data = next((acc for acc in data if acc["Id"] == account1), None)
    test_account_2_data = next((acc for acc in data if acc["Id"] == account2), None)

    assert test_account_1_data is not None
    assert test_account_2_data is not None

    assert test_account_1_data["Name"] == "Test Account 1"
    assert len(test_account_1_data["Tags"]) == 1
    assert test_account_1_data["Tags"][0]["Key"] == "Env"
    assert test_account_1_data["Tags"][0]["Value"] == "Dev"

    assert test_account_2_data["Name"] == "Test Account 2"
    assert len(test_account_2_data["Tags"]) == 0
