## Description

This project shows a quick way to authorize workloads on AWS to be able to obtain authorization from EntraID Applications.

The project is divided in two folder, simulating the different scopes: AWS and Azure (both an AWS and an Azure account are needed).

In AWS, create the cognito identity pool that will give us a JWT token that will be used to obtain an authenticated AzureAD token.
The AWS statefile will output the cognito identity pool and it will be read by the Azure IaC via data.
In Azure, terraform creates an application and it registers the identity created in cognito.

**Attention:** the secondss step requires a manual change to the code. It is not possible to read the id of an identity in Cognito Identity pools, nor it is possible to set it as output (because of ephemeral resources utilized).</br>
For these reasons, after running *10_aws_cognito_identity_pool*, navigate in the AWS console to Cognito and copy the just created idenity id, under *Identity Browser* tab (the Identity Pool Id can instead be fetched). Put the id as value of the *subject* field in *azuread_application_federated_identity_credential*.

#### Get the Cognito JWT

```bash
COGNITO_POOL_ID="us-east-1:aaaaaaaa-bbbb-bbbb-bbbb-cccccccccccc"
COGNITO_TOKEN=$(aws cognito-identity get-open-id-token-for-developer-identity \
--identity-pool-id ${COGNITO_POOL_ID} \
--logins entraid=AWS_Cognito_Identity_Pool \
--region us-east-1 | jq -r .Token)
```
#### Use the Cognito JWT to obtain an AzureAD JWT
[Reference](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-client-creds-grant-flow#third-case-access-token-request-with-a-federated-credential)

```bash
AZURE_TENANT_ID="aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
AZURE_APP_ID="bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"
curl -X POST "https://login.microsoftonline.com/${AZURE_TENANT_ID}/oauth2/v2.0/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials" \
  -d "scope=https://graph.microsoft.com/.default" \
  -d "client_id=${AZURE_APP_ID}" \
  -d "client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer" \
  -d "client_assertion=${COGNITO_TOKEN}"
```
