import { Construct } from "constructs";
import { DataAwsIamPolicyDocument } from "@cdktf/provider-aws/lib/data-aws-iam-policy-document";
import { IamRole } from "@cdktf/provider-aws/lib/iam-role";
import { IamPolicy } from "@cdktf/provider-aws/lib/iam-policy";
import { IamPolicyAttachment } from "@cdktf/provider-aws/lib/iam-policy-attachment";

export class StepFunctionIamRole extends Construct {
  public role: IamRole;

  constructor(scope: Construct, name: string, workerLambdaArn: string) {
    super(scope, name);

    const sfnAssumeRoleDoc = new DataAwsIamPolicyDocument(
      this,
      "sfnAssumeRoleDoc",
      {
        version: "2012-10-17",
        statement: [
          {
            effect: "Allow",
            principals: [
              {
                identifiers: ["states.amazonaws.com"],
                type: "Service",
              },
            ],
            actions: ["sts:AssumeRole"],
          },
        ],
      }
    );

    this.role = new IamRole(this, "snfRole", {
      name: "snfRole",
      assumeRolePolicy: sfnAssumeRoleDoc.json,
    });

    const logPermissionDoc = new DataAwsIamPolicyDocument(
      this,
      "logPermissionDoc",
      {
        version: "2012-10-17",
        statement: [
          {
            effect: "Allow",
            actions: [
              "logs:CreateLogDelivery",
              "logs:GetLogDelivery",
              "logs:UpdateLogDelivery",
              "logs:DeleteLogDelivery",
              "logs:ListLogDeliveries",
              "logs:PutResourcePolicy",
              "logs:DescribeResourcePolicies",
              "logs:DescribeLogGroups",
            ],
            resources: ["*"],
          },
        ],
      }
    );

    const sfnExecDoc = new DataAwsIamPolicyDocument(this, "sfnExecDoc", {
      version: "2012-10-17",
      statement: [
        {
          effect: "Allow",
          actions: [
            "states:StartExecution",
            "states:DescribeExecution",
            "states:StopExecution",
          ],
          resources: ["*"],
        },
      ],
    });

    const lamdbainvokeDoc = new DataAwsIamPolicyDocument(
      this,
      "lamdbainvokeDoc",
      {
        version: "2012-10-17",
        statement: [
          {
            effect: "Allow",
            actions: ["lambda:InvokeFunction"],
            resources: [`${workerLambdaArn}*`],
          },
        ],
      }
    );

    const lamdbainvokePolicy = new IamPolicy(this, "lamdbainvokePolicy", {
      name: "lamdbainvokePolicy",
      policy: lamdbainvokeDoc.json,
    });
    const logPermissionPolicy = new IamPolicy(this, "logPermissionPolicy", {
      name: "logPermissionPolicy",
      policy: logPermissionDoc.json,
    });

    const sfnExecPolicy = new IamPolicy(this, "sfnExecPolicy", {
      name: "sfnExecPolicy",
      policy: sfnExecDoc.json,
    });

    new IamPolicyAttachment(this, "attach1", {
      name: "lamdbainvokeAttach",
      policyArn: lamdbainvokePolicy.arn,
      roles: [this.role.name],
    });

    new IamPolicyAttachment(this, "attach2", {
      name: "logPermissionAttach",
      policyArn: logPermissionPolicy.arn,
      roles: [this.role.name],
    });

    new IamPolicyAttachment(this, "attach3", {
      name: "sfnExecAttach",
      policyArn: sfnExecPolicy.arn,
      roles: [this.role.name],
    });
  } // end constructor
}
