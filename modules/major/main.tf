data "azurerm_resource_group" "major" {
  name                                        = var.rg_name     
}

resource "azurerm_virtual_network" "major" {
  name                                        = "${var.name}-vnet"
  address_space                               = ["10.0.0.0/16"]
  location                                    = data.azurerm_resource_group.major.location
  resource_group_name                         = data.azurerm_resource_group.major.name
}
