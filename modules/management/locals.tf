locals {
  module_name    = "management_terraform_registry"
  module_version = "1.0.9"
  template_name  = var.enable_ipv6 ? "management_terraform_registry_dual_stack" : "management_terraform_registry"

  // Calculate IPv6 NIC address - use vnet module output for consistency with IPv4
  nic_ipv6_address = var.enable_ipv6 ? cidrhost(module.vnet.subnet_ipv6_prefixes[0], 10) : null

  // NSG IPv4 security rules
  nsg_ipv4_rules = [
    {
      name                       = "SSH"
      priority                   = "100"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_ranges         = "*"
      destination_port_ranges    = "22"
      description                = "Allow inbound SSH connection"
      source_address_prefix      = var.management_GUI_client_network
      destination_address_prefix = "*"
    },
    {
      name                       = "GAiA-portal"
      priority                   = "110"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_ranges         = "*"
      destination_port_ranges    = "443"
      description                = "Allow inbound HTTPS access to the GAiA portal"
      source_address_prefix      = var.management_GUI_client_network
      destination_address_prefix = "*"
    },
    {
      name                       = "SmartConsole-1"
      priority                   = "120"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_ranges         = "*"
      destination_port_ranges    = "18190"
      description                = "Allow inbound access using the SmartConsole GUI client"
      source_address_prefix      = var.management_GUI_client_network
      destination_address_prefix = "*"
    },
    {
      name                       = "SmartConsole-2"
      priority                   = "130"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_ranges         = "*"
      destination_port_ranges    = "19009"
      description                = "Allow inbound access using the SmartConsole GUI client"
      source_address_prefix      = var.management_GUI_client_network
      destination_address_prefix = "*"
    },
    {
      name                       = "Logs"
      priority                   = "140"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_ranges         = "*"
      destination_port_ranges    = "257"
      description                = "Allow inbound logging connections from managed gateways"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "ICA-pull"
      priority                   = "150"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_ranges         = "*"
      destination_port_ranges    = "18210"
      description                = "Allow security gateways to pull a SIC certificate"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "CRL-fetch"
      priority                   = "160"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_ranges         = "*"
      destination_port_ranges    = "18264"
      description                = "Allow security gateways to fetch CRLs"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "Policy-fetch"
      priority                   = "170"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_ranges         = "*"
      destination_port_ranges    = "18191"
      description                = "Allow security gateways to fetch policy"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]

  // NSG IPv6 security rules (conditional)
  nsg_ipv6_rules = var.enable_ipv6 && var.management_GUI_client_network_ipv6 != "" ? [
    {
      name                       = "SSH-IPv6"
      priority                   = "200"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_ranges         = "*"
      destination_port_ranges    = "22"
      description                = "Allow inbound SSH connection (IPv6)"
      source_address_prefix      = var.management_GUI_client_network_ipv6
      destination_address_prefix = "*"
    },
    {
      name                       = "GAiA-portal-IPv6"
      priority                   = "210"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_ranges         = "*"
      destination_port_ranges    = "443"
      description                = "Allow inbound HTTPS access to the GAiA portal (IPv6)"
      source_address_prefix      = var.management_GUI_client_network_ipv6
      destination_address_prefix = "*"
    },
    {
      name                       = "SmartConsole-1-IPv6"
      priority                   = "220"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_ranges         = "*"
      destination_port_ranges    = "18190"
      description                = "Allow inbound access using the SmartConsole GUI client (IPv6)"
      source_address_prefix      = var.management_GUI_client_network_ipv6
      destination_address_prefix = "*"
    },
    {
      name                       = "SmartConsole-2-IPv6"
      priority                   = "230"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_ranges         = "*"
      destination_port_ranges    = "19009"
      description                = "Allow inbound access using the SmartConsole GUI client (IPv6)"
      source_address_prefix      = var.management_GUI_client_network_ipv6
      destination_address_prefix = "*"
    }
  ] : []

  // Concatenate IPv4 and IPv6 rules
  nsg_base_security_rules = concat(local.nsg_ipv4_rules, local.nsg_ipv6_rules)
}
