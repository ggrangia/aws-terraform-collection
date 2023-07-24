/*
This class is not used in this project.
It is an example of how to create a cross account role
to be deployed in all your accounts.
The assume role policy (the one with "principals" and "sts.assumeRole" as action)
defines who (principal) is allowed to assume this role. It can be the Role of
the lambda used by the Step Function. Do not forget, on the lamdba side, to add the permission to
assume the cross-account role.
*/

import { Construct } from "constructs";
import { IamRole } from "@cdktf/provider-aws/lib/iam-role";
import { IamPolicyAttachment } from "@cdktf/provider-aws/lib/iam-policy-attachment";

export interface CrossAccountRoleOptions {
  principals: Array<string>;
  policiesArn: Array<string>;
}

export class CrossAccountRole extends Construct {
  public role: IamRole;

  constructor(
    scope: Construct,
    name: string,
    options: CrossAccountRoleOptions
  ) {
    super(scope, name);

    this.role = new IamRole(this, name, {
      name,
      assumeRolePolicy: JSON.stringify({
        version: "2012-10-17",
        statement: [
          {
            effect: "Allow",
            principals: [
              {
                identifiers: options.principals, // e.g the Role/user arn that wants to assume this role
                type: "AWS",
              },
            ],
            actions: ["sts:AssumeRole"],
          },
        ],
      }),
    });

    for (let policy of options.policiesArn) {
      new IamPolicyAttachment(this, "crossAccountPolicyAttach", {
        name: "crossAccountPolicyAttach",
        policyArn: policy,
        roles: [this.role.name],
      });
    }
  }
}
