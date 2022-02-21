terraform {
  required_version = ">=0.15"
  
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }

    backend "azurerm" {
      resource_group_name  = "rybitskyi"
      storage_account_name = "rybitskyistorage"
      container_name       = "tfstate"
      key                  = "terraform.tfstate"
    }

}

provider "azurerm" {

  features {}

#  subscription_id         = var.subscription_id
#  client_id               = var.client_id
#  client_secret           = var.client_secret
#  tenant_id               = var.tenant_id

}

