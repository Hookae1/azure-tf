variable "image_id" {
    type                            = string
    sensitive                       = true
}

variable "key_vault" {
    type                            = string
    sensitive                       = true  
}

variable "vmss_key" {
    type                            = string
}

variable "rgroup" {
    type                            = object({
        name                        = string
        location                    = string
    })
}

variable "vnet" {
    type                            = object({
        name                        = string
    })
}

variable "name" {
    type                            = string
}

variable "vmss_adpref" {
    type                            = list(string)
}

variable "rules" {
    type                            = map(object({
        name                        = string
        priority                    = number
        destination                 = string
    })) 
}

variable "ip" {
    type                            = object({
        version                     = string
        sku                         = string
    })                         
}

variable "application_port" {
    type                            = number
}

variable "set" {
    type = object({
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

