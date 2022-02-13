terraform {
  required_version = ">=0.15"
  
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {

  features {}

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

}

module "major" {
  source                                    = "./modules/major"

  rg_name                                   = var.resource_group.name
  location                                  = var.resource_group.location

  name                                      = var.project
  
}

/*
module "db" {
source                                      = "./modules/db"

}
*/

module "vmss" {
  source                                    = "./modules/vmss"

  image_id                                  = var.image_id
  key_vault                                 = var.key_vault
  key_name                                  = var.key_name
  
  name                                      = var.project
  rgroup                                    = module.major.rgroup
  vnet                                      = module.major.vnet
  
  rules                                     = var.rules
  ip                                        = var.ip
  application_port                          = var.application_port

  set                                       = var.set 

  admin_username                            = var.admin_username

  scale                                     = var.scale

}

