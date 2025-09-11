provider "aws" {
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

variables {}

run "create_bucket_plan" {
  command = plan

  variables {
    create_bucket = true
  }

  assert {
    condition     = startswith(output.s3_bucket_name, "some-bucket")
    error_message = "Implement the tests and terraform main plan."
  }
}

run "create_bucket_apply" {
  command = apply

  variables {
    create_bucket = true
  }

  assert {
    condition     = startswith(output.s3_bucket_name, "some-bucket")
    error_message = "Implement the tests and terraform main apply."
  }
}
