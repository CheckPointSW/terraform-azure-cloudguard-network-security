output "id" {
  value = local.create_new_nsg ? azurerm_network_security_group.nsg[0].id : var.nsg_id
}

output "name" {
  value = local.create_new_nsg ? azurerm_network_security_group.nsg[0].name : null
}
