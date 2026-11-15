locals {
  module_name    = "high_availability_terraform_registry"
  module_version = "1.0.9"
  extended_zone_region_map = {
    "losangeles" = ["westus"]
    "perth"      = ["australiaeast"]
  }

  # Determine if Availability Set should be created
  availability_set_condition = var.availability_type == "Availability Set" && var.extended_zone == "None"

  # Extended zone configuration
  edge_zone                       = var.extended_zone != "None" ? var.extended_zone : null
  storage_account_deployment_mode = var.extended_zone == "None" ? var.storage_account_deployment_mode : "None"

  # Mirrors the vnet submodule: subnets are created only when an address space is given.
  create_new_vnet = var.address_space != ""

  # Everything below iterates this list, so exposing eth3+ later is a change to this line only.
  additional_nic_indexes = var.deploy_additional_nic ? [2] : []
  public_ip_count        = length(var.vips_names) + 4 + length(local.additional_nic_indexes)
  additional_nics = {
    for eth_index in local.additional_nic_indexes : "eth${eth_index}" => {
      eth_index     = eth_index
      subnet_name   = var.additional_subnet_name
      subnet_prefix = var.additional_subnet_prefix
      start_address = var.additional_subnet_start_address
    }
  }

  member_additional_nics = merge([
    for eth_key, nic in local.additional_nics : {
      for member in [1, 2] : "${member}-${eth_key}" => merge(nic, {
        eth_key = eth_key
        member  = member
      })
    }
  ]...)

  additional_subnet_ids = {
    for eth_key, nic in local.additional_nics : eth_key => (
      local.create_new_vnet ? azurerm_subnet.additional[eth_key].id : data.azurerm_subnet.additional_existing[eth_key].id
    )
  }

  # On an existing vNet the real subnet prefix wins and additional_subnet_prefix is ignored, as for subnet1/2.
  additional_subnet_prefixes = {
    for eth_key, nic in local.additional_nics : eth_key => (
      local.create_new_vnet ? nic.subnet_prefix : data.azurerm_subnet.additional_existing[eth_key].address_prefixes[0]
    )
  }

  member_additional_nic_ids = {
    for member in [1, 2] : member => [
      for eth_index in local.additional_nic_indexes :
      azurerm_network_interface.additional["${member}-eth${eth_index}"].id
    ]
  }

  # Cross-repo contract: keys must match the ARM template and CGE's get_additional_cluster_vips.
  additional_cluster_vips = jsonencode({
    for eth_key, nic in local.additional_nics : eth_key => [
      {
        name             = "cluster-vip-${eth_key}"
        privateIPAddress = cidrhost(local.additional_subnet_prefixes[eth_key], nic.start_address + 2)
        publicIPAddress  = "${var.cluster_name}-${eth_key}"
      }
    ]
  })
}
