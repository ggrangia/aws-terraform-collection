import { Construct } from "constructs";
import { Lambda } from "./.gen/modules/lambda";

export class LambdaForStepFunc extends Construct {
  public lambda: Lambda;

  constructor(scope: Construct, name: string) {
    super(scope, name);

    this.lambda = new Lambda(this, "doStuff", {
      functionName: "doStuff",
      description: "My lambda that does a lot of stuff",
      handler: "index.lambda_handler",
      runtime: "python3.9",
      publish: true,
      sourcePath: "../../../lambda/index.py", // The path is relative to the output folder: cdktf.out/stack/name-of-the-stack
      environmentVariables: {
        WORK: "Yes",
      },
      layers: [
        "arn:aws:lambda:eu-west-1:017000801446:layer:AWSLambdaPowertoolsPythonV2:38",
      ],
    });
  }
}
