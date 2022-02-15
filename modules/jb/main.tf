
# Fetching SSH-key from Azure Key Vault for vmSS configuration
data "azurerm_key_vault_secret" "jb_key" {
  name                                              = var.jb_key
  key_vault_id                                      = var.key_vault
}

output "jb_key" {
  value                                             = data.azurerm_key_vault_secret.jb_key
  sensitive                                         = true
}

resource "azurerm_public_ip" "jumpbox" {
  name                                              = "${var.name}-jb-ip"
  location                                          = var.rgroup.location
  resource_group_name                               = var.rgroup.name
  allocation_method                                 = var.jb_ip.allocation_method
  ip_version                                        = var.jb_ip.ip_version
  sku                                               = var.jb_ip.sku
}

resource "azurerm_network_security_group" "jumpbox" {
  name                                              = "${var.name}-jb-nsg"
  location                                          = var.rgroup.location
  resource_group_name                               = var.rgroup.name

  security_rule {
      name                                          = "SSH"
      priority                                      = 101
      direction                                     = "Inbound"
      access                                        = "Allow"
      protocol                                      = "Tcp"
      source_port_range                             = "*"
      destination_port_range                        = "22"
      source_address_prefix                         = "*"
      destination_address_prefix                    = "*"
    }
}

resource "azurerm_network_interface" "jumpbox" {
  name                                              = "${var.name}-jb-nic"
  location                                          = var.rgroup.location
  resource_group_name                               = var.rgroup.name

  ip_configuration {
    name                                            = "IPConfiguration"
    subnet_id                                       = var.subnet.id
    private_ip_address_allocation                   = var.ip_allocation
    public_ip_address_id                            = azurerm_public_ip.jumpbox.id
  }
    depends_on                                      = [azurerm_network_security_group.jumpbox]
}

resource "azurerm_network_interface_security_group_association" "association" {
  network_interface_id                              = azurerm_network_interface.jumpbox.id
  network_security_group_id                         = azurerm_network_security_group.jumpbox.id
}

resource "azurerm_virtual_machine" "jumpbox" {
  name                                              = "${var.name}-vm-jb"
  location                                          = var.rgroup.location
  resource_group_name                               = var.rgroup.name
  network_interface_ids                             = [azurerm_network_interface.jumpbox.id]
  vm_size                                           = var.set.vm_size

  storage_image_reference {
    publisher                                       = var.set.image.publisher 
    offer                                           = var.set.image.offer   
    sku                                             = var.set.image.sku           
    version                                         = var.set.image.version  
  }

  storage_os_disk {
    name                                            = "${var.name}-jb-os-disk"
    caching                                         = var.set.os_disk.caching
    create_option                                   = var.set.os_disk.create_option
    managed_disk_type                               = var.set.os_disk.managed_disk_type
  }

  os_profile {
    computer_name                                   = "${var.name}-jb"
    admin_username                                  = var.admin_username
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path                                          = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data                                      = data.azurerm_key_vault_secret.jb_key.value
    }
  }
   depends_on                                       = [azurerm_network_interface.jumpbox]
}