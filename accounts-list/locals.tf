locals {
  org_event_pattern = {
    source = [
      "aws.organizations"
    ]
    detail = {
      eventName = [
        "CreateAccountResult",
        "CloseAccountResult",
        "MoveAccount",
        "RemoveAccountFromOrganization",
        "AcceptHandshake"
      ]
    }
  }
}
