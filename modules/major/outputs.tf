output "rgroup" {
  value = data.azurerm_resource_group.major
}

output "vnet" {
  value = azurerm_virtual_network.major
}

