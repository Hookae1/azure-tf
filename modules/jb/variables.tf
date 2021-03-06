variable "jb_key" {
    type                            = string     
}

variable "key_vault" {
    type                            = string
    sensitive                       = true       
}

variable "subnet" {
    type                            = object({
        id                          = string
    })
}

variable "ip_allocation" {
    type                            = string      
}

variable "rgroup" {
    type                            = object({
        name                        = string
        location                    = string
    })
}

variable "jb_ip" {
    type                            = object({
        allocation_method           = string
        ip_version                  = string
        sku                         = string
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
    
variable "set" {
    type                            = object({
        vm_size                     = string

        image                       = object({
            publisher               = string
            offer                   = string
            sku                     = string
            version                 = string
        })

        os_disk                     = object({
            caching                 = string
            create_option           = string
            managed_disk_type       = string
        })
    })                             
}

variable "admin_username" {
    type                            = string          
}