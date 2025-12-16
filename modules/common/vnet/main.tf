//********************** New Virtual Network **************************//
resource "azurerm_virtual_network" "vnet" {
  count               = local.create_new_vnet ? 1 : 0
  name                = var.vnet_name
  location            = var.location
  address_space       = [var.address_space]
  resource_group_name = var.resource_group_name
  dns_servers         = var.dns_servers
  tags                = merge(lookup(var.tags, "virtual-network", {}), lookup(var.tags, "all", {}))
}

resource "azurerm_subnet" "subnet" {
  depends_on = [
    azurerm_virtual_network.vnet
  ]
  count                = local.create_new_vnet ? length(var.subnet_names) : 0
  name                 = var.subnet_names[count.index]
  virtual_network_name = azurerm_virtual_network.vnet[0].name
  resource_group_name  = var.resource_group_name
  address_prefixes     = [var.subnet_prefixes[count.index]]
}

resource "azurerm_subnet_network_security_group_association" "security_group_frontend_association" {
  depends_on = [
    azurerm_virtual_network.vnet,
    azurerm_subnet.subnet[0]
  ]
  count                     = local.create_new_vnet ? 1 : 0
  subnet_id                 = azurerm_subnet.subnet[0].id
  network_security_group_id = var.nsg_id
}

resource "azurerm_subnet_network_security_group_association" "security_group_backend_association" {
  depends_on = [
    azurerm_virtual_network.vnet,
    azurerm_subnet.subnet[1]
  ]
  count                     = local.create_new_vnet ? (length(var.subnet_names) >= 2 ? 1 : 0) : 0
  subnet_id                 = azurerm_subnet.subnet[1].id
  network_security_group_id = var.nsg_id
}

resource "azurerm_route_table" "frontend" {
  count               = local.create_new_vnet ? 1 : 0
  name                = azurerm_subnet.subnet[0].name
  location            = var.location
  resource_group_name = var.resource_group_name

  route {
    name           = "Local-Subnet"
    address_prefix = azurerm_subnet.subnet[0].address_prefixes[0]
    next_hop_type  = local.next_hop_type_allowed_values[1]
  }

  route {
    name                   = "To-Internal"
    address_prefix         = var.address_space
    next_hop_type          = local.next_hop_type_allowed_values[3]
    next_hop_in_ip_address = join(".", [for i, v in split(".", element(split("/", azurerm_subnet.subnet[0].address_prefixes[0]), 0)) : i == 3 ? tostring(tonumber(v) + 4) : v])
  }

  tags = merge(lookup(var.tags, "route-table", {}), lookup(var.tags, "all", {}))
}

resource "azurerm_subnet_route_table_association" "frontend_association" {
  count          = local.create_new_vnet ? 1 : 0
  subnet_id      = azurerm_subnet.subnet[0].id
  route_table_id = azurerm_route_table.frontend[0].id
}

resource "azurerm_route_table" "backend" {
  count               = local.create_new_vnet ? (length(var.subnet_names) >= 2 ? 1 : 0) : 0
  name                = azurerm_subnet.subnet[1].name
  location            = var.location
  resource_group_name = var.resource_group_name

  route {
    name                   = "To-Internet"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = local.next_hop_type_allowed_values[3]
    next_hop_in_ip_address = join(".", [for i, v in split(".", element(split("/", azurerm_subnet.subnet[1].address_prefixes[0]), 0)) : i == 3 ? tostring(tonumber(v) + 4) : v])
  }

  tags = merge(lookup(var.tags, "route-table", {}), lookup(var.tags, "all", {}))
}

resource "azurerm_subnet_route_table_association" "backend_association" {
  count          = local.create_new_vnet ? (length(var.subnet_names) >= 2 ? 1 : 0) : 0
  subnet_id      = azurerm_subnet.subnet[1].id
  route_table_id = azurerm_route_table.backend[0].id
}

//********************** Existing Virtual Network **************************//
data "azurerm_subnet" "frontend" {
  count                = !local.create_new_vnet ? 1 : 0
  name                 = var.subnet_names[0]
  virtual_network_name = var.vnet_name
  resource_group_name  = var.existing_vnet_resource_group
}

data "azurerm_subnet" "backend" {
  count                = !local.create_new_vnet && length(var.subnet_names) >= 2 ? 1 : 0
  name                 = var.subnet_names[1]
  virtual_network_name = var.vnet_name
  resource_group_name  = var.existing_vnet_resource_group
}
