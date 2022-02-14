module "major" {
  source                                    = "./modules/major"

  rg_name                                   = var.resource_group.name
  location                                  = var.resource_group.location

  name                                      = var.project
  
}

/*
module "db" {
source                                      = "./modules/db"

}
*/

module "vmss" {
  source                                    = "./modules/vmss"

  image_id                                  = var.image_id
  key_vault                                 = var.key_vault
  key_name                                  = var.key_name
  
  name                                      = var.project
  rgroup                                    = module.major.rgroup
  vnet                                      = module.major.vnet
  
  rules                                     = var.rules
  ip                                        = var.ip
  application_port                          = var.application_port

  set                                       = var.vmss_set 

  admin_username                            = var.admin_username

  scale                                     = var.scale

}

module "jb" {
  source                                    = "./modules/jb"
  depends_on                                = [module.vmss, module.major]
  
  jb_ip                                     = var.jb_ip
  jbkey_name                                = var.jbkey_name
  key_vault                                 = var.key_vault

  name                                      = var.project
  rgroup                                    = module.major.rgroup
  vnet                                      = module.major.vnet

  set                                       = var.jb_set

  admin_username                            = var.admin_username
                
}

