variable "rgroup" {
    type                            = object({
        name                        = string
        location                    = string
    })
}

variable "vnet" {
    type                            = string
}

variable "name" {
  type                              = string
}

variable "sec_rule" {
    type                            = object({
        name                        = string
        priority                    = number
        destination                 = string
    }) 
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

variable "upgrade_policy" {
    type                            = string
}

variable "set" {
    sku                             = object({
        name                        = string
        tier                        = number
    })

    os                              = object({
        caching                     = string
        create_option               = string
        managed_disk_type           = string
    })
}

variable "admin_username" {
    type                            = string
}

variable "ssh" {
    type                            = string
    sensitive                       = true
}

variable "scale" {
    capa                            = object({
        minimum                     = number
        maximum                     = number
    })
  
}

variable "mt_rule" {
    type                            = object({
        operator                    = string
        threshold                   = number
        direction                   = string
    })
  
}
