
# Fetching custom VM image from Azure Gallery
data "azurerm_shared_image_version" "image" {
  name                                        = "0.0.1"
  image_name                                  = "vmImage"
  gallery_name                                = "yrGallery"
  resource_group_name                         = var.rgroup.name
}

output "image" {
  value                                       = data.azurerm_shared_image_version.image.id
}       

# Fetching SSH-key from Azure Key Vault for vmSS configuration
data "azurerm_key_vault_secret" "ssh_key" {
  name                                        = var.vmss_key
  key_vault_id                                = var.key_vault
}

output "ssh_key" {
  value                                       = data.azurerm_key_vault_secret.ssh_key.value
  sensitive                                   = true
}

# Creating Network + LB + vmSS
resource "azurerm_subnet" "vmss" {
  name                                        = "${var.name}-vmss-sub"
  resource_group_name                         = var.rgroup.name
  virtual_network_name                        = var.vnet.name
  address_prefixes                            = var.vmss_adpref
}

resource "azurerm_network_security_group" "public_nsg" {
  name                                        = "${var.name}-nsg"
  location                                    = var.rgroup.location
  resource_group_name                         = var.rgroup.name

   dynamic "security_rule" {
    for_each = var.rules
    content {
      name                                    = security_rule.value["name"]
      priority                                = security_rule.value["priority"]
      direction                               = "Inbound"
      access                                  = "Allow"
      protocol                                = "Tcp"
      source_port_range                       = "*"
      destination_port_range                  = security_rule.value["destination"]
      source_address_prefix                   = "*"
      destination_address_prefix              = "*"
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "association" {
  subnet_id                                   = azurerm_subnet.vmss.id
  network_security_group_id                   = azurerm_network_security_group.public_nsg.id
}

resource "azurerm_public_ip" "vmss" {
  name                                        = "${var.name}-vmss-ip"
  resource_group_name                         = var.rgroup.name
  location                                    = var.rgroup.location
  allocation_method                           = "Static"
  ip_version                                  = var.ip.version
  sku                                         = var.ip.sku
}

resource "azurerm_lb" "lb" {
  name                                        = "${var.name}-lb"
  location                                    = var.rgroup.location
  resource_group_name                         = var.rgroup.name
  sku                                         = "Standard"

  depends_on                                  = [azurerm_public_ip.vmss]

  frontend_ip_configuration {
    name                                      = "FrontEnd"
    public_ip_address_id                      = azurerm_public_ip.vmss.id
  }
}

resource "azurerm_lb_backend_address_pool" "lbback" {
  name                                        = "BackendAdressPool"
  loadbalancer_id                             = azurerm_lb.lb.id
}

resource "azurerm_lb_probe" "probe" {
  name                                        = "http-probe"
  resource_group_name                         = var.rgroup.name
  loadbalancer_id                             = azurerm_lb.lb.id
  port                                        = var.application_port
  protocol                                    = "Tcp"
}

resource "azurerm_lb_rule" "lbrules" {
        resource_group_name                   = var.rgroup.name
        loadbalancer_id                       = azurerm_lb.lb.id
        probe_id                              = azurerm_lb_probe.probe.id
#       backend_address_pool_id               = azurerm_lb_backend_address_pool.lbback.id
        frontend_ip_configuration_name        = "FrontEnd"
        name                                  = "${var.application_port}-lbrule"
        protocol                              = "Tcp"
        frontend_port                         = var.application_port
        backend_port                          = var.application_port

        depends_on                            = [azurerm_lb_probe.probe]
}



resource "azurerm_virtual_machine_scale_set" "vmss" {
  name                                        = "${var.name}-vmss"
  location                                    = var.rgroup.location
  resource_group_name                         = var.rgroup.name
  automatic_os_upgrade                        = false
  upgrade_policy_mode                         = var.set.upgrade_policy
  

  sku {
    name                                      = var.set.sku.name
    tier                                      = var.set.sku.tier
    capacity                                  = var.set.sku.capacity
  }

  storage_profile_image_reference {
    id                                        = data.azurerm_shared_image_version.image.id
  }
  storage_profile_os_disk {
    caching                                   = var.set.os_disk.caching
    create_option                             = var.set.os_disk.create_option
    managed_disk_type                         = var.set.os_disk.managed_disk_type
  }
  os_profile {
    computer_name_prefix                      = "${var.name}-vmss-vm"
    admin_username                            = var.admin_username
  }
  os_profile_linux_config {
    disable_password_authentication           = true

    ssh_keys {
    path                                      = "/home/${var.admin_username}/.ssh/authorized_keys"
    key_data                                  = data.azurerm_key_vault_secret.ssh_key.value
    }

  } 

  network_profile {
    name                                      = "vmss-net-profile"
    primary                                   = true

    ip_configuration { 
      name                                    = "IPConfiguration"
      primary                                 = true
      subnet_id                               = azurerm_subnet.vmss.id
      load_balancer_backend_address_pool_ids  = [azurerm_lb_backend_address_pool.lbback.id]
    }
  }
}

/*
resource "azurerm_virtual_machine_scale_set_extension" "script" {
  name                         = "${var.name}-custom"
  virtual_machine_scale_set_id = azurerm_virtual_machine_scale_set.vmss.id
  publisher                    = "Microsoft.Azure.Extensions"
  type                         = "CustomScript"
  type_handler_version         = "2.0"
  settings = <<SETTINGS
    {
        "commandToExecute": "    "
    }
SETTINGS
}
*/

resource "azurerm_monitor_autoscale_setting" "monitor" {
  name                                        = "${var.name}-autoscale"
  target_resource_id                          = azurerm_virtual_machine_scale_set.vmss.id
  location                                    = var.rgroup.location
  resource_group_name                         = var.rgroup.name

  profile {
    name                                      = "${var.name}-autoscale"

    capacity {
      default                                 = var.scale.default
      minimum                                 = var.scale.minimum
      maximum                                 = var.scale.maximum
    }

  rule {
      metric_trigger {
        metric_name                           = "Percentage CPU"
        metric_resource_id                    = azurerm_virtual_machine_scale_set.vmss.id
        time_grain                            = "PT1M"
        statistic                             = "Average"
        time_window                           = "PT5M"
        time_aggregation                      = "Average"
        operator                              = "GreaterThan"
        threshold                             = 50
      }
      scale_action {
        direction                             = "Increase"
        type                                  = "ChangeCount"
        value                                 = "1"
        cooldown                              = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name                           = "Percentage CPU"
        metric_resource_id                    = azurerm_virtual_machine_scale_set.vmss.id
        time_grain                            = "PT1M"
        statistic                             = "Average"
        time_window                           = "PT5M"
        time_aggregation                      = "Average"
        operator                              = "LessThan"
        threshold                             = 25
      }

      scale_action {
        direction                             = "Decrease"
        type                                  = "ChangeCount"
        value                                 = "1"
        cooldown                              = "PT1M"
      }
    }
  


  }
}