module "major" {
  source                                    = "./modules/major"

  rg_name                                   = var.resource_group.name
  location                                  = var.resource_group.location

  name                                      = var.project
}


module "db" {
source                                      = "./modules/db"

  name                                      = var.project
  rgroup                                    = module.major.rgroup
  vnet                                      = module.major.vnet
  key_vault                                 = var.key_vault

  fqdn                                      = var.mysql_fqdn
  mysql_adpref                              = var.mysql_adpref
  backup_retention_days                     = var.backup_retention_days
  sku_name                                  = var.sku_name
  mysql_version                             = var.db_version
  charset                                   = var.charset
  collation                                 = var.collation

  db_user                                   = var.db_user
  db_pass                                   = var.db_pass
}


module "vmss" {
  source                                    = "./modules/vmss"

  image_id                                  = var.image_id
  key_vault                                 = var.key_vault
  vmss_key                                  = var.vmss_key
  name                                      = var.project
  rgroup                                    = module.major.rgroup
  vnet                                      = module.major.vnet
  
  vmss_adpref                               = var.vmss_adpref
  rules                                     = var.rules
  ip                                        = var.ip
  application_port                          = var.application_port
  set                                       = var.vmss_set 
  admin_username                            = var.admin_username
  scale                                     = var.scale
}


module "jb" {
  source                                    = "./modules/jb"
  
  name                                      = var.project
  rgroup                                    = module.major.rgroup
  vnet                                      = module.major.vnet
  subnet                                    = module.vmss.subnet

  jb_ip                                     = var.jb_ip
  ip_allocation                             = var.ip_allocation
  jb_key                                    = var.jb_key
  key_vault                                 = var.key_vault
  set                                       = var.jb_set
  admin_username                            = var.admin_username              
}
