import { Construct } from "constructs";
import { App, TerraformStack } from "cdktf";
import { AwsProvider } from "@cdktf/provider-aws/lib/provider";

class MyStack extends TerraformStack {
  constructor(scope: Construct, id: string) {
    super(scope, id);

    new AwsProvider(this, "AWS", {
      region: "eu-west-1",
      accessKey: "",
      secretKey: "",
      defaultTags: [
        {
          tags: {
            "Environment": "Dev",
            "Owner": "ggrangia",
            "Alias": "tgw"
          }
        }
      ],
    });

    // define resources here

  }
}

const app = new App();
new MyStack(app, "parallel-lambda-step-function");
app.synth();
