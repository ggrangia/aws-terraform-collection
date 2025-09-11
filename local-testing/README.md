# Local Terraform Testing Example with Moto and Taskfile

This project demonstrates how to run [Terraform tests (tftest)](https://developer.hashicorp.com/terraform/tutorials/testing/tf-test) locally using [Moto](https://github.com/spulec/moto) to mock AWS services, and [Taskfile](https://taskfile.dev) to automate the workflow.

The whole terraform plan/test should be run via Taskfile to interact with moto.

## Features

- **Moto** runs in a Docker container to mock AWS APIs.
- **Taskfile** automates starting/stopping Moto and running Terraform commands.
- **Terraform** code and tests for a simple S3 bucket resource.
- **tftest** configuration for local test execution.

## Usage

```sh
task start-moto-server
```

```sh
task terraform-init
```

```sh
task terraform-plan
```

```sh
task stop-moto-server
```
