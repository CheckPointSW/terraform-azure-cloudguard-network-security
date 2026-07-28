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
  description = "The name of the virtual network used by the MDS."
  value       = module.vnet.name
}

output "subnet_ids" {
  description = "The IDs of the subnets used by the MDS."
  value       = module.vnet.subnets
}

output "nsg_id" {
  description = "The ID of the Network Security Group associated with the MDS."
  value       = module.network_security_group.id
}

output "nic_id" {
  description = "The ID of the primary network interface attached to the MDS."
  value       = azurerm_network_interface.nic.id
}

output "public_ip_address" {
  description = "The IPv4 public IP address of the MDS."
  value       = azurerm_public_ip.public_ip.ip_address
}

output "public_ip_dns_name" {
  description = "The fully qualified domain name (FQDN) of the MDS public IP."
  value       = azurerm_public_ip.public_ip.fqdn
}

output "vm_id" {
  description = "The ID of the MDS virtual machine."
  value       = azurerm_virtual_machine.mds_vm_instance.id
}

output "vm_name" {
  description = "The name of the MDS virtual machine."
  value       = azurerm_virtual_machine.mds_vm_instance.name
}

output "private_ip_address" {
  description = "The primary private IPv4 address of the MDS."
  value       = azurerm_network_interface.nic.ip_configuration[0].private_ip_address
}
