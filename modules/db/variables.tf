variable "rgroup" {
    type                                = object({
        name                            = string
        location                        = string
    })
}

variable "key_vault" {
    type                                = string
}

variable "vnet" {
    type                                = object({
        name                            = string
        id                              = string
    })
}

variable "name" {
    type                                = string
}

variable "fqdn" {
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

variable "mysql_version" {
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