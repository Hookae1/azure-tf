resource_group = {
    name                            = "rybitskyi"
    location                        = "eastus"                     
}

project                             = "eschool"

image_id                            = "/subscriptions/882d3802-7024-42ce-88b9-a109ec214b09/resourceGroups/rybitskyi/providers/Microsoft.Compute/galleries/yrGallery/images/vmImage/versions/0.0.1"
key_vault                           = "/subscriptions/882d3802-7024-42ce-88b9-a109ec214b09/resourceGroups/rybitskyi/providers/Microsoft.KeyVault/vaults/rybitskyikey"
key_name                            = "vmSS-eschool"


rules = {
    "SSH" = {
        name                        = "ssh-22"
        priority                    = 101
        destination                 = "22" 
    }

    "HTTP" = {
        name                        = "http-80"
        priority                    = 102
        destination                 = "80"         
    }

    "HTTP-8080" = {
        name                        = "http-8080"
        priority                    = 103
        destination                 = "8080"         
    }

    "HTTPS"     = {
        name                        = "https"
        priority                    = 104
        destination                 = "443"         
    } 
}

ip = {
    version                         = "IPv4"
    sku                             = "Standard"
}

application_port                    = "80"


set = {
    upgrade_policy                  = "Automatic"

    sku = {
        name                        = "Standard_B1ms"
        tier                        = "Standard"
        capacity                    = 1
    }

    os_disk = {
        caching                     = "ReadWrite"
        create_option               = "FromImage"
        managed_disk_type           = "Standard_LRS"
    }
}

admin_username                      = "eschool"

scale   = {
    default                         = 1
    minimum                         = 1
    maximum                         = 2
}
