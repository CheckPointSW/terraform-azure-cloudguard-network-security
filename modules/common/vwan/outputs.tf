output "hub_id" {
  value = local.create_new_vwan ? azurerm_virtual_hub.vwan_hub[0].id : data.azurerm_virtual_hub.vwan_hub[0].id
}

output "hub_virtual_router_asn" {
  value = local.create_new_vwan ? azurerm_virtual_hub.vwan_hub[0].virtual_router_asn : data.azurerm_virtual_hub.vwan_hub[0].virtual_router_asn
}

output "hub_virtual_router_ips" {
  value = local.create_new_vwan ? azurerm_virtual_hub.vwan_hub[0].virtual_router_ips : data.azurerm_virtual_hub.vwan_hub[0].virtual_router_ips
}
