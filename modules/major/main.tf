resource "azurerm_resource_group" "major" {
  name                                        = "${var.name}-rg"
  location                                    = var.location
}

resource "azurerm_virtual_network" "major" {
  name                                        = "${var.name}-vnet"
  address_space                               = ["10.0.0.0/16"]
  location                                    = azurerm_resource_group.major.name
  resource_group_name                         = azurerm_resource_group.major.location
}
