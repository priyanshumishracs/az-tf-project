terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">=1.10.5"
}

provider "azurerm" {
  features {}
  subscription_id = ""
  tenant_id       = ""
  client_id       = ""
  client_secret   = ""
}