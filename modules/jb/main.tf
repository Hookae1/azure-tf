
# Fetching SSH-key from Azure Key Vault for vmSS configuration
data "azurerm_key_vault_key" "jb_key" {
  name                                              = var.jbkey_name
  key_vault_id                                      = var.key_vault
}

output "ssh_key" {
  value                                             = data.azurerm_key_vault_key.jb_key.public_key_openssh
  sensitive                                         = true
}

resource "azurerm_subnet" "jumpbox" {
  name                                              = "${var.name}-jb-sub"
  resource_group_name                        	    = var.rgroup.name
  virtual_network_name                       	    = var.vnet.name
  address_prefixes                           	    = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "jumpbox" {
  name                                              = "${var.name}-jb-ip"
  location                                          = var.rgroup.location
  resource_group_name                               = var.rgroup.name
  allocation_method				    = "Static"
  ip_version                                        = var.jb_ip.ip_version
  sku                                               = var.jb_ip.sku
# domain_name_label                                 = "${random_string.fqdn.result}-ssh"
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
    subnet_id                                       = azurerm_subnet.jumpbox.id
    private_ip_address_allocation                   = "dynamic"
    public_ip_address_id                            = azurerm_public_ip.jumpbox.id
  }

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
      key_data                                      = data.azurerm_key_vault_key.jb_key.public_key_openssh
    }
  }

}
