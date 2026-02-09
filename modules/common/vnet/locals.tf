locals {
  // Create a new VNet only if address_space is provided
  create_new_vnet = var.address_space != "" ? true : false

  // Regex for validating CIDR notation
  regex_valid_network_cidr = "^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(/(3[0-2]|2[0-9]|1[0-9]|[0-9]))|$"

  // Regex for validating IPv6 VNet address space CIDR notation
  regex_valid_ipv6_vnet_cidr = "^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:))/(4[8-9]|5[0-9]|6[0-4])$"

  // Regex for validating IPv6 subnet CIDR notation
  // Azure requires subnets to be exactly /64 per official documentation refer to https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/ipv6-overview
  regex_valid_ipv6_subnet_cidr = "^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:))/64$"


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

  // For IPv6: Read from existing subnets when using existing VNet, otherwise use provided variables
  subnet_ipv6_prefixes = local.create_new_vnet ? var.subnet_ipv6_prefixes : (
    var.enable_ipv6 ? (
      length(var.subnet_names) == 1 ? 
        [data.azurerm_subnet.frontend[0].address_prefixes[1]] :
        [data.azurerm_subnet.frontend[0].address_prefixes[1], data.azurerm_subnet.backend[0].address_prefixes[1]]
    ) : []
  )

  // For IPv6 VNet address space: Read from existing VNet when using existing VNet, otherwise use provided variable
  vnet_ipv6_address_space = local.create_new_vnet ? var.ipv6_address_space : (
    var.enable_ipv6 ? data.azurerm_virtual_network.existing_vnet[0].address_space[1] : ""
  )
}
