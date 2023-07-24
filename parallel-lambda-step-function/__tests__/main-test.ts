import "cdktf/lib/testing/adapters/jest"; // Load types for expect matchers
import { Testing } from "cdktf";
import { StepFunctionIamRole } from "../iam";
import { MyStack } from "../mystack";
import { AwsProvider } from "@cdktf/provider-aws/lib/provider";
import { SfnStateMachine } from "@cdktf/provider-aws/lib/sfn-state-machine";
import { IamRole } from "@cdktf/provider-aws/lib/iam-role";

describe("My CDKTF Application", () => {
  // https://cdk.tf/testing

  let mystack: MyStack;
  let synthStack: string;
  let synthFull: string;

  beforeAll(() => {
    const app = Testing.app();
    mystack = new MyStack(app, "test_stack");
    synthStack = Testing.synth(mystack);
    synthFull = Testing.fullSynth(mystack);
  });

  it("check terraform configuration is valid", () => {
    expect(synthFull).toBeValidTerraform();
  });

  it("check if AWS Provider is included", () => {
    expect(synthStack).toHaveProvider(AwsProvider);
  });

  it("check if State Function is generated", () => {
    expect(synthStack).toHaveResource(SfnStateMachine);
  });

  /*
  it("check if the produced terraform configuration is planing successfully", () => {
    const app = Testing.app();
    const stack = new MyStack(app, "test");
    expect(Testing.fullSynth(stack)).toPlanSuccessfully();
  });
*/
  describe("Unit testing using assertions", () => {
    const stack = Testing.synthScope((scope) => {
      new StepFunctionIamRole(scope, "my-app-under-test", "lambdaArn");
    });

    it("should contain a resource", () => {
      expect(stack).toHaveResourceWithProperties(IamRole, {
        name: "snfRole",
      });
    });
  });
});
