## Description

This project shows a quick way to authorize workloads on AWS to be able to obtain authorization from EntraID Applications.

The project is divided in two folder, simulating the different scopes: AWS and Azure (both an AWS and an Azure account are needed).

In AWS, create the cognito identity pool that will give us a JWT token that will be used to obtain an authenticated AzureAD token.
The AWS statefile will output the cognito identity pool and it will be read by the Azure IaC via data.
In Azure, terraform creates an application and it registers the identity created in cognito.

**Attention:** the secondss step requires a manual change to the code. It is not possible to read the id of an identity in Cognito Identity pools, nor it is possible to set it as output (because of ephemeral resources utilized).</br>
For these reasons, after running *10_aws_cognito_identity_pool*, navigate in the AWS console to Cognito and copy the just created idenity id, under *Identity Browser* tab (the Identity Pool Id can instead be fetched). Put the id as value of the *subject* field in *azuread_application_federated_identity_credential*.