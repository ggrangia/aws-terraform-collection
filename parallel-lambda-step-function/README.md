This project is a simple example of how to perform a set of operations (Lambda function) in parallel thanks to Step Function Map workflow. The code is written is cdktf with very minimal test setup.

![Step Function](/parallel-lambda-step-function/img/stepFuncMap.jpg)

## Deployed Resources

The following resources will be deployed:

- 1 Lambda (using Lambda module)
- 1 Standard Lambda function

## Description

This solution may be very useful when you have to perform the same operation against a set of accounts in your Organization. The Step Function is set to use JSON input and pass every "item" to the lambda function. If an array is passed, every lambda receives a single element. If the array contains a list of accounts ID, each lambda recevies one account ID. It is then possible to assume a cross account role deployed in every account (non deployed in this example) to perform the necessary actions.

It is important to note that the Step function must be Standard to invoke all the lambdas in parallel.