
# Fetching the MySQL secrets from Azure Key Vault
data "azurerm_key_vault_secret" "db_user" {
  name                                    = var.db_user
  key_vault_id                            = var.key_vault
}

data "azurerm_key_vault_secret" "db_pass" {
  name                                    = var.db_pass
  key_vault_id                            = var.key_vault
}

output "db_user" {
  value                                   = data.azurerm_key_vault_secret.db_user.value
}

output "db_pass" {
  value                                   = data.azurerm_key_vault_secret.db_pass.value
  sensitive                               = true
}


# Generatin of randon dns name for MySQL
resource "random_string" "fqdn" {
 length                                   = var.fqdn.length
 special                                  = var.fqdn.special
 upper                                    = var.fqdn.upper
 number                                   = var.fqdn.number
}

# Creating MySQL Database
resource "azurerm_subnet" "mysql_subnet" {
  name                                    = "${var.name}-msubnet"
  resource_group_name                     = var.rgroup.name
  virtual_network_name                    = var.vnet.name
  address_prefixes                        = var.mysql_adpref
  service_endpoints                       = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_private_dns_zone" "mysql_dns" {
  name                                    = "${var.name}.mysql.database.azure.com"
  resource_group_name                     = var.rgroup.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysql_link" {
  name                                    = "mysql_link"
  private_dns_zone_name                   = azurerm_private_dns_zone.mysql_dns.name
  virtual_network_id                      = var.vnet.id
  resource_group_name                     = var.rgroup.name
}

resource "azurerm_mysql_flexible_server" "mysql" {
  name                                    = random_string.fqdn.id
  resource_group_name                     = var.rgroup.name
  location                                = var.rgroup.location
  administrator_login                     = data.azurerm_key_vault_secret.db_user.value
  administrator_password                  = data.azurerm_key_vault_secret.db_pass.value
  backup_retention_days                   = var.backup_retention_days
  delegated_subnet_id                     = azurerm_subnet.mysql_subnet.id
  private_dns_zone_id                     = azurerm_private_dns_zone.mysql_dns.id
  sku_name                                = var.sku_name
  version                                 = var.mysql_version 

  depends_on                              = [azurerm_private_dns_zone_virtual_network_link.mysql_link]
}

resource "azurerm_mysql_flexible_database" "database" {
  name                                    = var.name
  resource_group_name                     = var.rgroup.name
  server_name                             = azurerm_mysql_flexible_server.mysql.name
  charset                                 = var.charset
  collation                               = var.collation
}
