output "vmss_id" {
  description = "The ID of the Virtual Machine Scale Set."
  value       = local.vmss_id
}

output "vmss_name" {
  description = "The name of the Virtual Machine Scale Set."
  value       = local.vmss_name
}

output "vmss_identity_principal_id" {
  description = "The Principal ID of the VMSS system-assigned managed identity. Empty when custom metrics are disabled or in Flexible mode (SystemAssigned identity is unsupported on Flexible)."
  value       = var.enable_custom_metrics && !local.is_flexible ? azurerm_linux_virtual_machine_scale_set.vmss[0].identity[0].principal_id : ""
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

output "instance_public_ip_prefix_id" {
  description = "The ID of the public IP prefix the instance-level public IPs are allocated from. Null when instance_public_ip_prefix_mode is 'None'."
  value       = local.instance_public_ip_prefix_id
}

output "instance_public_ip_prefix_cidr" {
  description = "The CIDR of the public IP prefix created by the module (for example 20.61.14.0/28), which is the reserved range for instance public IPv4 addresses. Null unless instance_public_ip_prefix_mode is 'New'."
  value       = var.instance_public_ip_prefix_mode == "New" ? azurerm_public_ip_prefix.instance_level[0].ip_prefix : null
}

output "backend_lb_private_ip" {
  description = "The private IPv4 address of the backend load balancer frontend. Null when deployment_mode is 'External' or 'None'."
  value       = local.create_backend_lb ? azurerm_lb.backend_lb[0].frontend_ip_configuration[0].private_ip_address : null
}
