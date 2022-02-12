locals {
  instance_count                              = 1
}

# Pull the image of VM from Azure Gallery
data "azurerm_shared_image_version" "image" {
  name                                        = "0.0.1"
  image_name                                  = "vmImage"
  gallery_name                                = "yrGallery"
  resource_group_name                         = var.rgroup.name
}

output "image_id" {
  value = "/subscriptions/882d3802-7024-42ce-88b9-a109ec214b09/resourceGroups/rybitskyi/providers/Microsoft.Compute/galleries/yrGallery/images/vmImage/versions/0.0.1"
}

#Creating Network + LB + vmSS
resource "azurerm_subnet" "vmss" {
  name                                        = "${var.name}-vmss-sub"
  resource_group_name                         = var.rgroup.name
  virtual_network_name                        = var.vnet.name
  address_prefixes                            = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "public_nsg" {
  name                                        = "${var.name}-nsg"
  location                                    = var.rgroup.location
  resource_group_name                         = var.rgroup.name

   dynamic "security_rule" {
    for_each = var.sec_rule
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

  depends_on                                  = ["azurerm_public_ip_lbip"]

  frontend_ip_configuration {
    name                                      = "FrontEnd"
    public_ip_address_id                      = azurerm_public_ip.vmss.id
  }
}

resource "azurerm_lb_backend_address_pool" "lbback" {
  name                                        = "BackendAdressPool"
  resource_group_name                         = var.rgroup.name
  loadbalancer_id                             = azurerm_lb.lb.id
}

resource "azurerm_lb_probe" "probe" {
  name                                        = "ssh-probe"
  resource_group_name                         = var.rgroup.name
  loadbalancer_id                             = azurerm_lb.lb.id
  port                                        = var.application_port
  protocol                                    = "Tcp"
}

resource "azurerm_lb_rule" "lbrules" {

        resource_group_name                   = var.rgroup.name
        loadbalancer_id                       = azurerm_lb.lb.id
        probe_id                              = azurerm_lb_probe.probe.id
        backend_address_pool_id               = azurerm_lb_backend_address_pool.lbback.id
        frontend_ip_configuration_name        = "FrontEnd"
        name                                  = "${var.application_port}-lbrule"
        protocol                              = "Tcp"
        frontend_port                         = var.application_port
        backend_port                          = var.application_port

        depends_on                            = ["azurerm_lb_probe.probe"]
}

resource "azurerm_virtual_machine_scale_set" "vmss" {
  name                                        = "${var.name}-vmss"
  location                                    = var.rgroup.location
  resource_group_name                         = var.rgroup.name
  automatic_os_upgrade                        = true
  upgrade_policy_mode                         = var.upgrade_policy
  

  sku {
    name                                      = var.set.sku.name
    tier                                      = var.set.sku.tier
    capacity                                  = local.instance_count
  }


  storage_profile_image_reference {
    id                                        = "${data.azurerm_shared_image_version.image.id}"
  }

  storage_profile_os_disk {
    name                                      = "${var.name}-os-disk"
    caching                                   = var.set.os.caching
    create_option                             = var.set.os.create_option
    managed_disk_type                         = var.set.os.disk_type
  }

  os_profile {
    computer_name_prefix                      = "${var.name}-vmss-vm"
    admin_username                            = var.admin_username
  }

  os_profile_linux_config {
    disable_password_authentication   = true

    ssh_keys {
    path                                      = "/home/${var.admin_username}/.ssh/authorized_keys"
    key_data                                  = var.ssh
    }

  } 

  network_profile {
    name                                      = "vmss-net-profile"
    primary                                   = true

    ip_configuration {
      name                                    = "IPConfiguration"
      subnet_id                               = azurerm_subnet.vmss.id
      load_balancer_backend_address_pool_ids  = [azurerm_lb_backend_address_pool.lbback.id]
    }
  }
}

#resource "azurerm_virtual_machine_scale_set_extension" "script" {
#  name                         = "${var.name}-custom"
#  virtual_machine_scale_set_id = azurerm_virtual_machine_scale_set.vmss.id
#  publisher                    = "Microsoft.Azure.Extensions"
#  type                         = "CustomScript"
#  type_handler_version         = "2.0"
#  settings = <<SETTINGS
#    {
#        "commandToExecute": "    "
#    }
#SETTINGS
#}


resource "azurerm_monitor_autoscale_setting" "monitor" {
  name                                        = "${var.name}-autoscale"
  target_resource_id                          = azurerm_virtual_machine_scale_set.vmss.id
  location                                    = var.rgroup.location
  resource_group_name                         = var.rgroup.name

  profile {
    name                                      = "${var.name}-autoscale"

    capacity {
      default                                 = local.instance_count
      minimum                                 = var.scale.capa.min
      maximum                                 = var.scale.capa.max
    }

    dynamic "rule" {
      for_each                                = var.mt_rule
      content {
        metric_trigger {
          metric_name                         = "Percentage CPU"
          metric_resource_id                  = azurerm_virtual_machine_scale_set.vmss.id
          time_grain                          = "PT1M"
          statistic                           = "Average"
          time_window                         = "PT5M"
          time_aggregation                    = "Average"
          operator                            = rule.value["operator"]
          threshold                           = rule.value["threshold"]
        }
      }
     

      scale_action {
        direction                             = rule.value["direction"]
        type                                  = "ChangeCount"
        value                                 = "1"
        cooldown                              = "PT1M"
      }
    }
  }
}