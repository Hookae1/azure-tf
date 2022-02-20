output "fqdn" {
   value                    = module.db.fqdn
}
output "vmss_name" {
   value                    = module.vmss.vmss_name
}       

output "vmss_public_ip" {
    value                   = module.vmss.public_ip
}

output "user_name" {
    value                   = module.vmss.user_name
}   

output "jb_ip" {
    value                   = module.jb.public_ip               
}

output "jb_name" {
    value                   = module.jb.jb_name             
}

