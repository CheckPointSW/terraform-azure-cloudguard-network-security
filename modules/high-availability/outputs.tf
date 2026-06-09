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
  description = "The name of the virtual network used by the cluster."
  value       = module.vnet.name
}

output "subnet_ids" {
  description = "The IDs of the subnets used by the cluster [frontend, backend]."
  value       = module.vnet.subnets
}

output "nsg_id" {
  description = "The ID of the Network Security Group associated with the cluster."
  value       = module.network_security_group.id
}

output "cluster_member_public_ips" {
  description = "The IPv4 public IP addresses of the two cluster members."
  value       = azurerm_public_ip.public_ip[*].ip_address
}

output "cluster_member_public_ip_dns_names" {
  description = "The FQDNs of the two cluster members' public IPs."
  value       = azurerm_public_ip.public_ip[*].fqdn
}

output "cluster_vip_public_ip" {
  description = "The cluster VIP public IPv4 address."
  value       = azurerm_public_ip.cluster_vip.ip_address
}

output "cluster_vip_dns_name" {
  description = "The FQDN of the cluster VIP public IP."
  value       = azurerm_public_ip.cluster_vip.fqdn
}

output "cluster_vip_id" {
  description = "The resource ID of the cluster VIP public IP."
  value       = azurerm_public_ip.cluster_vip.id
}

output "vips_public_ips" {
  description = "The public IPv4 addresses of additional cluster VIPs (one per entry in vips_names)."
  value       = azurerm_public_ip.vips[*].ip_address
}

output "vips_dns_names" {
  description = "The FQDNs of additional cluster VIPs (one per entry in vips_names)."
  value       = azurerm_public_ip.vips[*].fqdn
}

output "public_ip_prefix_id" {
  description = "The ID of the public IP prefix created for the cluster. Null when not created."
  value       = var.use_public_ip_prefix && var.create_public_ip_prefix ? azurerm_public_ip_prefix.public_ip_prefix[0].id : null
}

output "lb_external_id" {
  description = "The ID of the external (frontend) load balancer."
  value       = azurerm_lb.frontend_lb.id
}

output "lb_external_public_ip" {
  description = "The public IPv4 address of the external (frontend) load balancer."
  value       = azurerm_public_ip.public_ip_lb.ip_address
}

output "lb_external_public_ip_dns_name" {
  description = "The FQDN of the external (frontend) load balancer's public IP."
  value       = azurerm_public_ip.public_ip_lb.fqdn
}

output "lb_internal_id" {
  description = "The ID of the internal (backend) load balancer."
  value       = azurerm_lb.backend_lb.id
}

output "lb_internal_private_ip" {
  description = "The private IPv4 address of the internal (backend) load balancer frontend."
  value       = azurerm_lb.backend_lb.frontend_ip_configuration[0].private_ip_address
}

output "availability_set_id" {
  description = "The ID of the Availability Set used by the cluster. Null when deploying to Availability Zones or an extended zone."
  value       = local.availability_set_condition ? azurerm_availability_set.availability_set[0].id : null
}

output "vm_ids" {
  description = "The IDs of the cluster member virtual machines (length matches number_of_vm_instances)."
  value = concat(
    azurerm_virtual_machine.vm_instance_availability_set[*].id,
    azurerm_virtual_machine.vm_instance_availability_zone[*].id,
    azurerm_linux_virtual_machine.vm_instance_availability_zone_extended[*].id,
  )
}

output "vm_names" {
  description = "The names of the cluster member virtual machines."
  value = concat(
    azurerm_virtual_machine.vm_instance_availability_set[*].name,
    azurerm_virtual_machine.vm_instance_availability_zone[*].name,
    azurerm_linux_virtual_machine.vm_instance_availability_zone_extended[*].name,
  )
}
