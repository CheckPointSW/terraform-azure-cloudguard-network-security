locals {
  // Create a new VNet only if address_space is provided
  create_new_vnet = var.address_space != "" ? true : false

  // Regex for validating CIDR notation
  regex_valid_network_cidr = "^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(/(3[0-2]|2[0-9]|1[0-9]|[0-9]))|$"

  next_hop_type_allowed_values = [
    "VirtualNetworkGateway",
    "VnetLocal",
    "Internet",
    "VirtualAppliance",
    "None"
  ]

  subnets = local.create_new_vnet ? azurerm_subnet.subnet.*.id : (
    length(var.subnet_names) == 1 ? [data.azurerm_subnet.frontend[0].id] :
    [data.azurerm_subnet.frontend[0].id, data.azurerm_subnet.backend[0].id]
  )

  subnet_prefixes = local.create_new_vnet ? azurerm_subnet.subnet.*.address_prefixes[*][0] : (
    length(var.subnet_names) == 1 ? [data.azurerm_subnet.frontend[0].address_prefixes[0]] :
    [data.azurerm_subnet.frontend[0].address_prefixes[0], data.azurerm_subnet.backend[0].address_prefixes[0]]
  )
}
