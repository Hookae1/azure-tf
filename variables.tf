
#=================== Service Principal Data =================== #
variable "subscription_id" {
type                                    = string
sensitive                               = true                
}

variable "client_id" {
type                                    = string
sensitive                               = true                 
}

variable "client_secret" {
type                                    = string               
}

variable "tenant_id" {
type                                    = string
sensitive                               = true                 
}


#========================== Generall ========================= #
variable "resource_group" {
type                                    = object({
    name                                = string
    location                            = string
    })     
}

variable "project" {
type                                    = string
}

variable "admin_username" {
type                                    = string
}

variable "storage_name" {
    type                                = string
}

variable "container_name" {
    type                                = string  
}

variable "access_key" {
    type                                = string     
}

#=========================== MySQL =========================== #
variable "mysql_fqdn" {
    type                                = object({
       length                           = number
       special                          = bool
       upper                            = bool
       number                           = bool
    })        
}

variable "mysql_adpref" {
    type                                = list(string)
} 

variable "backup_retention_days" {
    type                                = number      
}

variable "sku_name" {
    type                                = string
}

variable "db_version" {
    type                                = string
}

variable "db_user" {
    type                                = string  
}

variable "db_pass" {
    type                                = string
    sensitive                           = true 
}

variable "charset" {
    type                                = string    
}

variable "collation" {
    type                                = string        
}

#========================= LB + vmSS ========================= #
variable "image_id" {
    type                                 = string
    sensitive                            = true
}

variable "key_vault" {
    type                                = string
    sensitive                           = true  
}

variable "vmss_key" {
    type                                = string
}

variable "vmss_adpref" {
    type                                = list(string)
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

variable "scale" {
    type                                = object({
        default                         = number
        minimum                         = number
        maximum                         = number
    })
}

#=========================== Jumpbox =========================== #
variable "jb_key" {
    type                                = string 
}

variable "jb_ip" {
    type                                = object({
        allocation_method               = string
        ip_version                      = string
        sku                             = string
    })      
}

variable "ip_allocation" {
    type                                = string      
}

variable "application_port" {
    type                                = number
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

