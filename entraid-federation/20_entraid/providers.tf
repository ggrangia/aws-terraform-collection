terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.1.0"
    }
  }
  required_version = "~> 1.10"
}

provider "azuread" {}
