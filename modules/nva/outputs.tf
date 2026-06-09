output "resource_group_name" {
  description = "The name of the managed-application Resource Group created for the NVA."
  value       = azurerm_resource_group.managed_app_rg.name
}

output "resource_group_id" {
  description = "The ID of the managed-application Resource Group created for the NVA."
  value       = azurerm_resource_group.managed_app_rg.id
}

output "resource_group_location" {
  description = "The location of the managed-application Resource Group created for the NVA."
  value       = azurerm_resource_group.managed_app_rg.location
}

output "managed_app_id" {
  description = "The ID of the Microsoft.Solutions managed application that provisions the NVA."
  value       = azapi_resource.managed_app.id
}

output "managed_app_name" {
  description = "The name of the Microsoft.Solutions managed application that provisions the NVA."
  value       = azapi_resource.managed_app.name
}

output "managed_resource_group_id" {
  description = "The ID of the managed resource group that contains the NVA resources deployed by the managed application."
  value       = "/subscriptions/${var.subscription_id}/resourcegroups/${var.nva_rg_name}"
}

output "managed_app_identity_id" {
  description = "The ID of the user-assigned managed identity used by the managed application."
  value       = azurerm_user_assigned_identity.managed_app_identity.id
}

output "managed_app_identity_principal_id" {
  description = "The principal ID of the user-assigned managed identity used by the managed application."
  value       = azurerm_user_assigned_identity.managed_app_identity.principal_id
}

output "vwan_hub_id" {
  description = "The ID of the Virtual WAN hub used (or created) for the NVA."
  value       = module.vwan.hub_id
}

output "vwan_hub_virtual_router_asn" {
  description = "The ASN of the Virtual WAN hub's built-in router."
  value       = module.vwan.hub_virtual_router_asn
}

output "vwan_hub_virtual_router_ips" {
  description = "The IP addresses of the Virtual WAN hub's built-in router."
  value       = module.vwan.hub_virtual_router_ips
}

output "image_version" {
  description = "The CloudGuard NVA image version selected for deployment."
  value       = element(local.image_versions, length(local.image_versions) - 1)
}

output "routing_intent_id" {
  description = "The ID of the routing-intent resource for the hub. Null when no routing intent policies are enabled."
  value       = length(local.routing_intent_policies) != 0 ? azapi_resource.routing_intent[0].id : null
}
