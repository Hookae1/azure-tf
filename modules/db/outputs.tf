output "fqdn" {
    value = azurerm_mysql_flexible_server.mysql.fqdn
}

output "mysql_user" {
    value = data.azurerm_key_vault_secret.db_user
}

output "mysql_upass" {
    value = data.azurerm_key_vault_secret.db_pass
}
