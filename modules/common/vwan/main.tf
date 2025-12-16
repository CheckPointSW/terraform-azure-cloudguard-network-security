//********************** New Virtual WAN **************************//
resource "azurerm_virtual_wan" "vwan" {
  count               = local.create_new_vwan ? 1 : 0
  name                = var.vwan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = merge(lookup(var.tags, "virtual-wan", {}), lookup(var.tags, "all", {}))
}

resource "azurerm_virtual_hub" "vwan_hub" {
  count               = local.create_new_vwan ? 1 : 0
  name                = var.vwan_hub_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_prefix      = var.vwan_hub_address_prefix
  virtual_wan_id      = azurerm_virtual_wan.vwan[0].id
  tags                = merge(lookup(var.tags, "virtual-hub", {}), lookup(var.tags, "all", {}))
}

//********************** Existing Virtual WAN **************************//
data "azurerm_virtual_hub" "vwan_hub" {
  count               = local.create_new_vwan ? 0 : 1
  name                = var.vwan_hub_name
  resource_group_name = var.vwan_hub_resource_group
}
