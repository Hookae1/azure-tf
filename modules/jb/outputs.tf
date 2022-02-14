output "public_ip" {
    value                   = azurerm_public_ip.jumpbox.ip_address
}

output "jb_name" {
    value                   = azurerm_virtual_machine.jumpbox.name
}