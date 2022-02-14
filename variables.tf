
# Service Principal data
variable "subscription_id" {
    type                                 = string
    sensitive                            = true                 
}

variable "client_id" {
    type                                 = string
    sensitive                            = true                 
}

variable "client_secret" {
    type                                 = string
    sensitive                            = true                 
}

variable "tenant_id" {
    type                                 = string
    sensitive                            = true                 
}


# General configuration
variable "resource_group" {
    type                                 = object({
        name                             = string
        location                         = string
    })     
}

variable "project" {
    type                                 = string
}

# LB + vmSS
variable "image_id" {
    type                                 = string
    sensitive                            = true
}

variable "key_vault" {
    type                                = string
    sensitive                           = true  
}

variable "key_name" {
    type                                = string
}

variable "rules" {
    type                                = map(object({
        name                            = string
        priority                        = number
        destination                     = string
    })) 
}

variable "ip" {
    type                                = object({
        version                         = string
        sku                             = string
    })                         
}

variable "application_port" {
    type                                = number
}

variable "jbkey_name" {
    type                                = string
     
}

variable "vmss_set" {
    type                                = object({  
        upgrade_policy                  = string

        sku                             = object({
            name                        = string
            tier                        = string
            capacity                    = number
        })

        os_disk                         = object({
            caching                     = string
            create_option               = string
            managed_disk_type           = string
        })
    }) 
}

variable "admin_username" {
    type                                = string
}

variable "scale" {
    type                                = object({
        default                         = number
        minimum                         = number
        maximum                         = number
    })
}

# Jumpbox

variable "jb_ip" {
    type                                = object({
        ip_version                      = string
        sku                             = string
    })      
}

variable "jb_set" {
    type                                = object({
        vm_size                         = string

        image                           = object({
            publisher                   = string
            offer                       = string
            sku                         = string
            version                     = string
        })

        os_disk                         = object({
            caching                     = string
            create_option               = string
            managed_disk_type           = string
        })
    })                             
}
