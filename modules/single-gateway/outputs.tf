output "resource_group_name" {
  description = "The name of the Resource Group."
  value       = module.common.resource_group_name
}

output "resource_group_id" {
  description = "The ID of the Resource Group."
  value       = module.common.resource_group_id
}

output "resource_group_location" {
  description = "The location of the Resource Group."
  value       = module.common.resource_group_location
}

output "vnet_name" {
  description = "The name of the virtual network used by the gateway."
  value       = module.vnet.name
}

output "subnet_ids" {
  description = "The IDs of the subnets used by the gateway [frontend, backend]."
  value       = module.vnet.subnets
}

output "nsg_id" {
  description = "The ID of the Network Security Group associated with the gateway."
  value       = module.network_security_group.id
}

output "frontend_nic_id" {
  description = "The ID of the frontend (eth0) network interface."
  value       = azurerm_network_interface.nic.id
}

output "backend_nic_id" {
  description = "The ID of the backend (eth1) network interface."
  value       = azurerm_network_interface.nic1.id
}

output "public_ip_address" {
  description = "The IPv4 public IP address of the gateway."
  value       = azurerm_public_ip.public_ip.ip_address
}

output "public_ip_dns_name" {
  description = "The fully qualified domain name (FQDN) of the gateway's public IP."
  value       = azurerm_public_ip.public_ip.fqdn
}

output "public_ipv6_address" {
  description = "The IPv6 public IP address of the gateway. Null when IPv6 is disabled."
  value       = var.enable_ipv6 ? azurerm_public_ip.public_ip_v6[0].ip_address : null
}

output "frontend_private_ip_address" {
  description = "The primary private IPv4 address of the gateway's frontend interface."
  value       = azurerm_network_interface.nic.ip_configuration[0].private_ip_address
}

output "backend_private_ip_address" {
  description = "The primary private IPv4 address of the gateway's backend interface."
  value       = azurerm_network_interface.nic1.ip_configuration[0].private_ip_address
}

output "vm_id" {
  description = "The ID of the gateway virtual machine (zonal or extended-zone)."
  value       = var.extended_zone == "None" ? azurerm_virtual_machine.single_gateway_vm_instance[0].id : azurerm_linux_virtual_machine.single_gateway_vm_instance_extended[0].id
}

output "vm_name" {
  description = "The name of the gateway virtual machine."
  value       = var.single_gateway_name
}

output "ipv6_lb_id" {
  description = "The ID of the IPv6 load balancer. Null when IPv6 is disabled."
  value       = var.enable_ipv6 ? azurerm_lb.lb_v6[0].id : null
}
