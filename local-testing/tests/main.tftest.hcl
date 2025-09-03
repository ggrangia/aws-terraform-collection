provider "aws" {
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

variables {}

run "valid_plan" {
  command = plan

  assert {
    condition     = output.s3_name == 2
    error_message = "Implement the tests and terraform main plan."
  }
}

run "valid_apply" {
  command = apply

  assert {
    condition     = output.s3_name == 2
    error_message = "Implement the tests and terraform main apply."
  }
}
