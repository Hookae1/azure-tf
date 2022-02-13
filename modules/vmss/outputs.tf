output "public_ip" {
    value                   = azurerm_public_ip.vmss.ip_address
}

output "user_name" {
    value                   = var.admin_username
}

output "vmss_name" {
    value                   = azurerm_virtual_machine_scale_set.vmss.name
}

output "key_name" {
    value                   = var.key_name
}
