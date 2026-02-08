output "id" {
  value = local.create_new_vnet ? azurerm_virtual_network.vnet[0].id : null
}

output "name" {
  value = local.create_new_vnet ? azurerm_virtual_network.vnet[0].name : var.vnet_name
}

output "location" {
  value = local.create_new_vnet ? azurerm_virtual_network.vnet[0].location : var.location
}

output "address_spaces" {
  value = local.create_new_vnet ? azurerm_virtual_network.vnet[0].address_space : [var.address_space]
}

output "subnets" {
  value = local.subnets
}

output "subnet_prefixes" {
  value = local.subnet_prefixes
}

output "allocation_method" {
  value = var.allocation_method
}

output "ipv6_enabled" {
  value = var.enable_ipv6
}

output "ipv6_address_space" {
  value = var.enable_ipv6 ? var.ipv6_address_space : null
}

output "subnet_ipv6_prefixes" {
  value = var.enable_ipv6 ? var.subnet_ipv6_prefixes : []
}
