
#========================== Generall ========================= #
resource_group = {
    name                            = "rybitskyi"
    location                        = "eastus"                     
}

project                             = "eschool"
admin_username                      = "eschool"
storage_name                        = "rybitskyistorage"
container_name                      = "tfstate"
access_key                          = "terraform.tfstate"

#========================= Datasource ======================== #
image_id                            = "/subscriptions/882d3802-7024-42ce-88b9-a109ec214b09/resourceGroups/rybitskyi/providers/Microsoft.Compute/galleries/yrGallery/images/vmImage/versions/0.0.1"
key_vault                           = "/subscriptions/882d3802-7024-42ce-88b9-a109ec214b09/resourceGroups/rybitskyi/providers/Microsoft.KeyVault/vaults/rybitskyikey"

vmss_key                            = "vmss-ssh"
jb_key                              = "jbox-ssh"
db_user                             = "mysqluser"
db_pass                             = "mysqluserpass"


#=========================== MySQL =========================== #

mysql_fqdn = {
    length                          = 6
    special                         = false
    upper                           = false
    number                          = false
}

mysql_adpref                        = ["10.0.5.0/24"]
backup_retention_days               = 7
sku_name                            = "B_Standard_B1ms"
db_version                          = "8.0.21"
charset                             = "utf8"
collation                           = "utf8_unicode_ci"


#========================= LB + vmSS ========================= #
vmss_adpref                         = ["10.0.1.0/24"]

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

application_port                    = "8080"


vmss_set = {
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

scale   = {
    default                         = 1
    minimum                         = 1
    maximum                         = 2
}

#=========================== Jumpbox ========================== #
jb_ip = {
    allocation_method               = "Static"
    ip_version                      = "IPv4"
    sku                             = "Standard"
}

ip_allocation                       = "dynamic"

jb_set = {
    vm_size                         = "Standard_B1ms"

    image = {
        publisher                   = "Canonical"
        offer                       = "0001-com-ubuntu-server-focal"
        sku                         = "20_04-lts-gen2"
        version                     = "latest"
    }

    os_disk = {
        caching                     = "ReadWrite"
        create_option               = "FromImage"
        managed_disk_type           = "Standard_LRS"
    }
}        