output "vmss_id" {
  description = "The ID of the Virtual Machine Scale Set."
  value       = azurerm_linux_virtual_machine_scale_set.vmss.id
}

output "vmss_name" {
  description = "The name of the Virtual Machine Scale Set."
  value       = azurerm_linux_virtual_machine_scale_set.vmss.name
}

output "vmss_identity_principal_id" {
  description = "The Principal ID of the VMSS system-assigned managed identity. Empty when custom metrics are disabled."
  value       = var.enable_custom_metrics ? azurerm_linux_virtual_machine_scale_set.vmss.identity[0].principal_id : ""
}

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

output "subnet_ids" {
  description = "The IDs of the subnets used by the VMSS [frontend, backend]."
  value       = module.vnet.subnets
}

output "nsg_id" {
  description = "The ID of the Network Security Group used by the VMSS."
  value       = module.network_security_group.id
}

output "frontend_lb_id" {
  description = "The ID of the frontend load balancer. Null when deployment_mode is 'Internal' or 'None'."
  value       = local.create_frontend_lb ? azurerm_lb.frontend_lb[0].id : null
}

output "backend_lb_id" {
  description = "The ID of the backend load balancer. Null when deployment_mode is 'External' or 'None'."
  value       = local.create_backend_lb ? azurerm_lb.backend_lb[0].id : null
}

output "frontend_lb_public_ip" {
  description = "The public IP address of the frontend load balancer. Null when deployment_mode is 'Internal' or 'None'."
  value       = local.create_frontend_lb ? azurerm_public_ip.public_ip_lb[0].ip_address : null
}

output "frontend_lb_public_ip_dns_name" {
  description = "The FQDN of the frontend load balancer's public IP. Null when deployment_mode is 'Internal' or 'None'."
  value       = local.create_frontend_lb ? azurerm_public_ip.public_ip_lb[0].fqdn : null
}

output "backend_lb_private_ip" {
  description = "The private IPv4 address of the backend load balancer frontend. Null when deployment_mode is 'External' or 'None'."
  value       = local.create_backend_lb ? azurerm_lb.backend_lb[0].frontend_ip_configuration[0].private_ip_address : null
}
