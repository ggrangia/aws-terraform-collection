import { Construct } from "constructs";
import { App, TerraformStack } from "cdktf";
import { AwsProvider } from "@cdktf/provider-aws/lib/provider";
import { SfnStateMachine } from "@cdktf/provider-aws/lib/sfn-state-machine";
import { StepFunctionIamRole } from "./iam";
import { LambdaForStepFunc } from "./lambda";

class MyStack extends TerraformStack {
  constructor(scope: Construct, id: string) {
    super(scope, id);

    new AwsProvider(this, "AWS", {
      region: "eu-west-1",
      defaultTags: [
        {
          tags: {
            Environment: "Dev",
            Owner: "ggrangia",
            Alias: "step-function-lambda",
          },
        },
      ],
    });

    const workLambda = new LambdaForStepFunc(this, "doStuff");

    const sfnRole = new StepFunctionIamRole(
      this,
      "sfnRole",
      workLambda.lambda.lambdaFunctionArnOutput
    );

    new SfnStateMachine(this, "WorkStateMachine", {
      name: "WorkStateMachine",
      roleArn: sfnRole.role.arn,
      // Definition exported from the console
      definition: JSON.stringify({
        Comment: "A description of my state machine",
        StartAt: "Map",
        States: {
          Map: {
            Type: "Map",
            ItemProcessor: {
              ProcessorConfig: {
                Mode: "DISTRIBUTED",
                ExecutionType: "EXPRESS",
              },
              StartAt: "Lambda Invoke",
              States: {
                "Lambda Invoke": {
                  Type: "Task",
                  Resource: "arn:aws:states:::lambda:invoke",
                  OutputPath: "$.Payload",
                  Parameters: {
                    "Payload.$": "$",
                    FunctionName: workLambda.lambda.lambdaFunctionArnOutput, //"arn:aws:lambda:eu-west-1:605665581171:function:stepfunctest:$LATEST"
                  },
                  Retry: [
                    {
                      ErrorEquals: [
                        "Lambda.ServiceException",
                        "Lambda.AWSLambdaException",
                        "Lambda.SdkClientException",
                        "Lambda.TooManyRequestsException",
                      ],
                      IntervalSeconds: 2,
                      MaxAttempts: 6,
                      BackoffRate: 2,
                    },
                  ],
                  End: true,
                },
              },
            },
            End: true,
            Label: "Map",
            MaxConcurrency: 1000,
          },
        },
        TimeoutSeconds: 600,
      }),
    });
  }
}

const app = new App();
new MyStack(app, "parallel-lambda-step-function");
app.synth();
