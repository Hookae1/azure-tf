output "public_ip" {
    value                   = azurerm_public_ip.vmss.ip_address
}

output "user_name" {
    value                   = var.admin_username
}

output "vmss_name" {
    value                   = azurerm_virtual_machine_scale_set.vmss.name
}

output "vmss_key" {
    value                   = var.vmss_key
}

output "subnet" {
    value                   = azurerm_subnet.vmss          
}
